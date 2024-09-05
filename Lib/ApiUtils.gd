extends Node

## 节点信号
func _ready():
	for type in API_TYPE:
		$"../Tab/Config/API Config/API/Box/ApiList".add_item(type)
		%APIMod.add_item(type)
	var dir = Global.readjson()["api"]
	for key in dir:
		if dir[key][0]:
			%ApiURL.text = dir[key][1]
			%ApiKey.text = dir[key][2]
			break

func _api_switch_pressed():
	var mod = API_TYPE[$"../Tab/Config/API Config/API/Box/ApiList".selected]
	var dir = Global.readjson()
	if dir["api"].has(mod):
		%ApiURL.text = dir["api"][mod][1]
		%ApiKey.text = dir["api"][mod][2]
		%APIMod.selected = $"../Tab/Config/API Config/API/Box/ApiList".selected
		$"../Tab/Config/API Config/API/Box/ApiState".text = mod + " active."
	else:
		$"../Tab/Config/API Config/API/Box/ApiState".text = "This API has not been stored."

func _set_api_default_pressed():
	var mod = API_TYPE[$"../Tab/Config/API Config/API/Box/ApiList".selected]
	var dir = Global.readjson()
	for key in dir["api"]:
		if dir["api"][key][0]:
			dir["api"][key][0] = false
			break
	if dir["api"].has(mod):
		dir["api"][mod][0] = true
	else:
		_update()
		dir["api"][mod] = [true, api_url, api_key]
	var save_file = FileAccess.open(Global.SAVEPATH, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(dir))
	save_file.close()
	$"../Tab/Config/API Config/API/Box/ApiState".text = mod + " has been set as default."

## API工具
var api_url : String
var api_key : String
var api_mod : int
var _quality : String
var time_out : int
var prompt : String

func _update():
	api_url = %ApiURL.text
	api_key = %ApiKey.text
	api_mod = %APIMod.selected
	_quality = %ImageQ.text
	time_out = %Timeout.value
	prompt = %Prompt.text

func lock_input(lock : bool):
	%ApiURL.set_editable(!lock)
	%ApiKey.set_editable(!lock)
	%APIMod.set_disabled(lock)
	%ImageQ.set_disabled(lock)
	%Timeout.set_editable(!lock)
	%Prompt.set_editable(!lock)
	$"../PromptSave/Load".set_disabled(lock)

func api_save():
	_update()
	var mod : String = API_TYPE[api_mod]
	var dir = Global.readjson()
	if dir["api"].has(mod):
		var is_de := false
		for key in dir["api"]:
			if dir["api"][key][0] and key == mod:
				is_de = true
				break
		dir["api"][mod] = [is_de, api_url, api_key]
	else:
		dir["api"][mod] = [false, api_url, api_key]
	var save_data = FileAccess.open(Global.SAVEPATH, FileAccess.WRITE)
	save_data.store_string(JSON.stringify(dir))
	save_data.close()

#func is_api_id(url : String) -> int:
	#if url.ends_with("/v1/services/aigc/multimodal-generation/generation"):
		#return 2
	#elif url.ends_with("v1/messages") or (API_TYPE[api_mod] == "claude"):
		#return 4
	#elif url.begins_with("http://127.0.0.1/v1/chat/completions"):
		#return 5
	#elif url.ends_with("/v1/chat/completions"):
		#return 0
	#else:
		#return 6

# API运行
const API_TYPE = ["gpt-4o-2024-08-06", "gpt-4o-mini", "qwen-vl-plus", \
					"qwen-vl-max", "claude", "gemini-1.5-pro-exp-0801", "local", "???"]
var API_FUNC : Array[Callable] = [Callable(self,"openai_api"), 
								Callable(self,"openai_api"),
								Callable(self,"qwen_api"), 
								Callable(self,"qwen_api"), 
								Callable(self,"claude_api"),
								Callable(self,"gemini_api"),
								Callable(self,"openai_api"), 
								Callable(self,"openai_api")]
func run_api(image_path: String) -> String:
	api_save()
	if image_path.is_empty():
		return "There are no pictures."
	var base64image = Global.image_to_base64(image_path, _quality)
	var current_prompt = Global.addition_prompt(prompt, image_path)
	var result = await API_FUNC[api_mod].call(current_prompt, base64image)
	return result

# 标准化收发
func get_result(head : PackedStringArray, data : String, url : String = "") -> Array:
	retry_times = 0
	if url.is_empty():
		url = api_url
	var response : String = await request_retry(head, data, url)
	if "Error:" in response:
		return [false, response]
	else:
		var json_result = JSON.parse_string(response)
		return [true, json_result]
# 重试方法
const RETRY_ATTEMPTS = 5
var retry_times : int = 0
const status_list = [429, 500, 502, 503, 504]
func request_retry(head : PackedStringArray, data : String, url : String) -> String:
	# 建立请求
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.timeout = time_out
	var error = http_request.request(url, head, HTTPClient.METHOD_POST, data)
	if error != OK:
		return "Error: " + error_string(error)
	
	# 发起成功
	var received = await http_request.request_completed
	http_request.queue_free()
	if received[0] != 0:
		return "Error: " + ClassDB.class_get_enum_constants("HTTPRequest", "Result")[received[0]]
	
	# 重试策略
	if retry_times > RETRY_ATTEMPTS:
		return "Error: Retry count exceeded"
	elif received[1] != 200 and status_list.has(received[1]) and retry_times <= RETRY_ATTEMPTS:
		retry_times += 1
		await get_tree().create_timer(2 ** (retry_times - 1)).timeout
		return await request_retry(head, data, url)
	elif received[1] == 200:
		var result : String = received[3].get_string_from_utf8()
		if "error" in result:
			return "APIError: " + result
		else:
			return result
	else:
		return "Error: Unknown error"


## 各家API模块

var formatrespon : bool = false:
	get:
		formatrespon = $"../SchemaBox/Schema".button_pressed
		return formatrespon
var format : Dictionary = {}

func openai_api(inputprompt : String, base64image : String):
	var temp_data = {
		"model": API_TYPE[api_mod],
		"messages": [
				{
				"role": "user",
				"content":
						[{"type": "image_url", 
						"image_url":
							{"url": "data:image/jpeg;base64," + base64image,
							"detail": _quality}
						},
						{"type": "text", "text": inputprompt}]
				}
					],
		"max_tokens": 300
		}
	var headers : PackedStringArray = ["Content-Type: application/json", 
										"Authorization: Bearer " + api_key]
	if formatrespon and !Global.is_run:
		format = %SchemaBox.send()
		if !format.is_empty():
			temp_data["response_format"] = format
	var data = JSON.stringify(temp_data)
	Global.is_run = true
	
	var result = await get_result(headers, data)
	if result[0]:
		var answer : String = ""
		var json_result = result[1]
		if json_result != null:
			# 安全地尝试
			if json_result.has("choices") and json_result["choices"].size() > 0 and\
					json_result["choices"][0].has("message") and\
					json_result["choices"][0]["message"].has("content"):
				var format_respon = JSON.parse_string(json_result["choices"][0]["message"]["content"])
				if !format_respon or (api_mod != 0 or api_mod != 1):
					answer = json_result["choices"][0]["message"]["content"]
				else:
					answer = get_openai_format_answer(format_respon)
			else:
				answer = str(json_result)
		return answer
	elif !result[0]:
		return result[1]
var batchmod = false
func get_openai_format_answer(json : Dictionary, tab : int = 0) -> String:
	var answer : String = ""
	if batchmod:
		for key in json:
			var unit_answer : String
			if json[key] is Dictionary:
				unit_answer = get_openai_format_answer(json[key])
			else:
				unit_answer = str(json[key]) + ", "
			answer = unit_answer + answer
	else:
		for key in json:
			var unit_answer : String
			if json[key] is Dictionary:
				unit_answer = "\n" + get_openai_format_answer(json[key], tab + 1)
			else:
				unit_answer = str(json[key])
			var _tab : String
			var tabar : Array = []
			tabar.resize(tab)
			tabar.fill("\t")
			_tab = "".join(tabar)
			answer = answer + _tab + key + ": " + unit_answer + ", \n"
		while answer.ends_with(", \n"):
			answer = answer.substr(0, len(answer) - 3)
	return answer


func gemini_api(inputprompt : String, base64image : String):
	var tempprompt = inputprompt
	#var gemini_format
	#if formatrespon and !Global.is_run:
		#format = %SchemaBox.send()
		#if !format.is_empty():
			#gemini_format = format["json_schema"]["schema"]  "properties"  "required"
	#Global.is_run = true
	if !("Return output in json format:" in inputprompt):
		tempprompt += "Return output in json format: {description: description, \
						features: [feature1, feature2, feature3, etc]}"
	var data = JSON.stringify(
			{
			"contents": [
				{"parts": [
						{"text": tempprompt},
						{"inline_data": {"mime_type": "image/jpeg",
										"data": base64image}}
							]}
						]
			})
	var headers : PackedStringArray = ["Content-Type: application/json"]
	var url : String = api_url + "/models/gemini-1.5-pro-exp-0801:generateContent?key=" + api_key
	# https://generativelanguage.googleapis.com/v1beta
	var result = await get_result(headers, data, url)
	if result[0]:
		var answer : String = ""
		var json_result = result[1]
		if json_result != null:
			# 安全地尝试
			if (json_result.has("candidates") and json_result["candidates"].size() > 0) and\
					json_result["candidates"][0].has("content") and\
					(json_result["candidates"][0]["content"].has("parts") and \
					json_result["candidates"][0]["content"]["parts"].size() > 0) and \
					json_result["candidates"][0]["content"]["parts"][0].has("text"):
				var format_respon = JSON.parse_string(json_result["candidates"][0]["content"]["parts"][0]["text"])
				if format.is_empty() and !format_respon:
					answer = json_result["candidates"][0]["content"]["parts"][0]["text"]
				else:
					answer = get_gemini_format_answer(format_respon)
			else:
				answer = str(json_result)
		return answer
	elif !result[0]:
		return result[1]
func get_gemini_format_answer(json : Dictionary):
	var answer : String = ""
	for key in json:
		var unit_answer : String
		if json[key] is Dictionary:
			unit_answer = get_gemini_format_answer(json[key])
		else:
			unit_answer = str(json[key]) + ", "
		answer = (unit_answer + answer).format(" ","[").format(" ", "]")
	return answer


func qwen_api(inputprompt : String, base64image : String):
	var data = JSON.stringify({
		"model": API_TYPE[api_mod],
		"input": {
			"messages": [
				{"role": "system",
				"content": [{"text": "You are a helpful assistant."}]},
				{"role": "user",
				"content": [{"image": "data:image/jpeg;base64," + base64image},
							{"text": inputprompt}]}
						]
				}
								})
	var headers : PackedStringArray = ["Authorization: Bearer " + api_key,
										"Content-Type: application/json"]
	
	var result = await get_result(headers, data)
	if result[0]:
		var answer = ""
		var json_result = result[1]
		if json_result != null:
			# 安全地尝试
			if json_result.has("output") and\
				json_result["output"].has("choices") and\
				json_result["output"]["choices"].size() > 0 and\
				json_result["output"]["choices"][0].has("message") and\
				json_result["output"]["choices"][0]["message"].has("content") and\
				json_result["output"]["choices"][0]["message"]["content"].size() > 0 and\
				json_result["output"]["choices"][0]["message"]["content"][0].has("text"):
				answer = json_result["output"]["choices"][0]["message"]["content"][0]["text"]
			else:
				answer = str(json_result)
		return answer
	elif !result[0]:
		return result[1]


func claude_api(inputprompt : String, base64image : String):
	var data = JSON.stringify({
		"model": "claude_api",
		"max_tokens": 300,
		"messages": [{
					"role": "user", 
					"content": [{
							"type": "image", 
							"source": {"type": "base64",
									"media_type": "image/jpeg",
									"data": base64image}
								},
								{
							"type": "text", 
							"text": inputprompt
								}]
					}]
							})
	var headers : PackedStringArray = ["Content-Type: application/json",
			"x-api-key:" + api_key,
			"anthropic-version: 2023-06-01"]
	
	var result = await get_result(headers, data)
	if result[0]:
		var answer : String = ""
		var json_result = result[1]
		if json_result != null:
			# 安全地尝试
			if json_result.has("content") and\
				json_result["content"].size() > 0 and\
				json_result["content"][0].has("text"):
				answer = json_result["content"][0]["text"]
			else:
				answer = str(json_result)
		return answer
	elif !result[0]:
		return result[1]

