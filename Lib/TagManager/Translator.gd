extends Node

func chinese_translator(text : String):
	var headers : PackedStringArray = ["Content-Type:application/x-www-form-urlencoded"]
	var data = "appid=105&sgid=en&sbid=en&egid=zh-CN&ebid=zh-CN&content=" + text + "&type=2"
	var url = "https://translate-api-fykz.xiangtatech.com/translation/webs/index"
	
	var result = await get_result(url,headers,data)
	if result[0]:
		var answer : String = ""
		var json_result = result[1]
		if json_result.has("by"):
			answer = json_result["by"]
		else:
			answer = "Error"
		return answer
	elif !result[0]:
		return result[1]

func gpt_translator(text : String, api_key : String):
	var headers = ["Content-Type: application/json",
					"Authorization: Bearer " + api_key]
	var data = JSON.stringify({
			"model": "gpt-3.5-turbo",
			"messages": [{"role": "user", 
						"content": "你是一个英译中专家，请直接返回" + text + \
							"最有可能的三种中文翻译结果，彼此间语义有所区分，结果以逗号间隔."}]
							})
	var url = "https://api.openai.com/v1/chat/completions"
	
	var result = await get_result(url,headers,data)
	if result[0]:
		var answer : String = ""
		var json_result = result[1]
		if json_result != null:
			# 安全地尝试
			if json_result.has("choices") and\
				json_result["choices"].size() > 0 and\
				json_result["choices"][0].has("message") and\
				json_result["choices"][0]["message"].has("content"):
				answer = json_result["choices"][0]["message"]["content"]
			else:
				answer = str(json_result)
		return answer
	elif !result[0]:
		return result[1]

func wait_http():
	while Global.maxhttp == 0:
		await get_tree().create_timer(3).timeout
	return true

func get_result(api_url : String, head : PackedStringArray, data : String) -> Array:
	if Global.maxhttp > 0:
		Global.maxhttp -= 1
		retry_times = 0
		var response : String = await request_retry(api_url, head, data)
		Global.maxhttp += 1
		if "Error:" in response:
			return [false, response]
		else:
			var json_result = JSON.parse_string(response)
			return [true, json_result]
	else:
		await wait_http()
		var result : Array = await get_result(api_url, head, data)
		return result

const RETRY_ATTEMPTS = 5
var retry_times : int = 0
const status_list = [429, 500, 502, 503, 504]
func request_retry(url : String, head : PackedStringArray, data : String) -> String:
	# 建立请求
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.timeout = 30
	var error = http_request.request(url, head, HTTPClient.METHOD_POST, data)
	if error != OK:
		return "Error: " + error_string(error)
	
	# 发起成功
	var received = await http_request.request_completed
	if received[0] != 0:
		return "Error: " + ClassDB.class_get_enum_constants("HTTPRequest", "Result")[received[0]]
	
	# 重试策略
	if retry_times > RETRY_ATTEMPTS:
		return "Error: Retry count exceeded"
	elif received[1] != 200 and status_list.has(received[1]) and retry_times <= RETRY_ATTEMPTS:
		retry_times += 1
		await get_tree().create_timer(2 ** (retry_times - 1)).timeout
		return await request_retry(url, head, data)
	elif received[1] == 200:
		var result : String = received[3].get_string_from_utf8()
		if "error" in result:
			return "APIError: " + result
		else:
			return result
	else:
		return "Error: Unknown error"
