extends LinkButton

var releases_url = "https://api.github.com/repos/SleeeepyZhou/VLMCaption-TagCraft/releases/latest"
@export var version = "V0.3.1-Beta"

func _ready():
	text = "Version " + version
	var temp_an = await retry_get()
	var an = JSON.parse_string(temp_an)
	var new_version = an["tag_name"]
	if new_version == version:
		$"../Tip".text = "already latest"
		$"../Tip".underline = LinkButton.UNDERLINE_MODE_NEVER
	else:
		$"../Tip".text = "new version " + an["tag_name"] + " available for download."
		$"../Tip".underline = LinkButton.UNDERLINE_MODE_ALWAYS
		var win_download : String = ""
		var lin_download : String = ""
		var mac_download : String = ""
		for v in an["assets"]:
			if "WIN" in v["name"].to_upper():
				win_download = v["browser_download_url"]
			elif "LINUX" in v["name"].to_upper():
				lin_download = v["browser_download_url"]
			elif "MAC" in v["name"].to_upper():
				mac_download = v["browser_download_url"]
		if OS.get_name() == "Windows":
			$"../Tip".uri = win_download
		elif OS.get_name() == "Linux":
			$"../Tip".uri = lin_download
		elif OS.get_name() == "macOS":
			$"../Tip".uri = mac_download
		else:
			$"../Tip".uri = "https://github.com/SleeeepyZhou/VLMCaption-TagCraft"

# 重试方法
const RETRY_ATTEMPTS = 5
var retry_times : int = 0
const status_list = [429, 500, 502, 503, 504]
func retry_get():
	# 建立请求
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.timeout = 10
	var error = http_request.request(releases_url)
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
		return await retry_get()
	elif received[1] == 200:
		var result : String = received[3].get_string_from_utf8()
		if "error" in result:
			return "Get_Error: " + result
		else:
			return result
	else:
		return "Error: Unknown error. Status:" + str(received[1]) + received[3].get_string_from_utf8()
'''
tag_name
browser_download_url
{
	"url":"https://api.github.com/repos/SleeeepyZhou/VLMCaption-TagCraft/releases/176266941",
	"assets_url":"https://api.github.com/repos/SleeeepyZhou/VLMCaption-TagCraft/releases/176266941/assets",
	"upload_url":"https://uploads.github.com/repos/SleeeepyZhou/VLMCaption-TagCraft/releases/176266941/assets{?name,label}",
	"html_url":"https://github.com/SleeeepyZhou/VLMCaption-TagCraft/releases/tag/V0.2.9-Beta",
	"id":176266941,
	"author":{
		"login":"SleeeepyZhou",
		"id":80639626,
		"node_id":"MDQ6VXNlcjgwNjM5NjI2",
		"avatar_url":"https://avatars.githubusercontent.com/u/80639626?v=4",
		"gravatar_id":"",
		"url":"https://api.github.com/users/SleeeepyZhou",
		"html_url":"https://github.com/SleeeepyZhou",
		"followers_url":"https://api.github.com/users/SleeeepyZhou/followers",
		"following_url":"https://api.github.com/users/SleeeepyZhou/following{/other_user}",
		"gists_url":"https://api.github.com/users/SleeeepyZhou/gists{/gist_id}",
		"starred_url":"https://api.github.com/users/SleeeepyZhou/starred{/owner}{/repo}",
		"subscriptions_url":"https://api.github.com/users/SleeeepyZhou/subscriptions",
		"organizations_url":"https://api.github.com/users/SleeeepyZhou/orgs",
		"repos_url":"https://api.github.com/users/SleeeepyZhou/repos",
		"events_url":"https://api.github.com/users/SleeeepyZhou/events{/privacy}",
		"received_events_url":"https://api.github.com/users/SleeeepyZhou/received_events",
		"type":"User",
		"site_admin":false
				},
	"node_id":"RE_kwDOMiwPNM4KgZ69",
	"tag_name":"V0.2.9-Beta",
	"target_commitish":"main",
	"name":"V0.2.9-Beta",
	"draft":false,
	"prerelease":false,
	"created_at":"2024-09-06T15:19:39Z",
	"published_at":"2024-09-22T07:15:10Z",
	"assets":[
		{
			"url":"https://api.github.com/repos/SleeeepyZhou/VLMCaption-TagCraft/releases/assets/194144830",
			"id":194144830,"node_id":"RA_kwDOMiwPNM4Lkmo-",
			"name":"Linux.V0.2.9-beta.zip",
			"label":null,
			"uploader":{
				"login":"SleeeepyZhou",
				"id":80639626,
				"node_id":"MDQ6VXNlcjgwNjM5NjI2",
				"avatar_url":"https://avatars.githubusercontent.com/u/80639626?v=4",
				"gravatar_id":"",
				"url":"https://api.github.com/users/SleeeepyZhou",
				"html_url":"https://github.com/SleeeepyZhou",
				"followers_url":"https://api.github.com/users/SleeeepyZhou/followers",
				"following_url":"https://api.github.com/users/SleeeepyZhou/following{/other_user}",
				"gists_url":"https://api.github.com/users/SleeeepyZhou/gists{/gist_id}",
				"starred_url":"https://api.github.com/users/SleeeepyZhou/starred{/owner}{/repo}",
				"subscriptions_url":"https://api.github.com/users/SleeeepyZhou/subscriptions",
				"organizations_url":"https://api.github.com/users/SleeeepyZhou/orgs",
				"repos_url":"https://api.github.com/users/SleeeepyZhou/repos",
				"events_url":"https://api.github.com/users/SleeeepyZhou/events{/privacy}",
				"received_events_url":"https://api.github.com/users/SleeeepyZhou/received_events",
				"type":"User",
				"site_admin":false
						},
			"content_type":"application/x-zip-compressed",
			"state":"uploaded",
			"size":22478031,
			"download_count":1,
			"created_at":"2024-09-22T07:14:44Z",
			"updated_at":"2024-09-22T07:14:53Z",
			"browser_download_url":"https://github.com/SleeeepyZhou/VLMCaption-TagCraft/releases/download/V0.2.9-Beta/Linux.V0.2.9-beta.zip"
		},{
			"url":"https://api.github.com/repos/SleeeepyZhou/VLMCaption-TagCraft/releases/assets/194144835",
			"id":194144835,
			"node_id":"RA_kwDOMiwPNM4LkmpD",
			"name":"TagCraft.winV0.2.9-beta_x86_64.zip",
			"label":null,
			"uploader":{
				"login":"SleeeepyZhou",
				"id":80639626,
				"node_id":"MDQ6VXNlcjgwNjM5NjI2",
				"avatar_url":"https://avatars.githubusercontent.com/u/80639626?v=4",
				"gravatar_id":"",
				"url":"https://api.github.com/users/SleeeepyZhou",
				"html_url":"https://github.com/SleeeepyZhou",
				"followers_url":"https://api.github.com/users/SleeeepyZhou/followers",
				"following_url":"https://api.github.com/users/SleeeepyZhou/following{/other_user}",
				"gists_url":"https://api.github.com/users/SleeeepyZhou/gists{/gist_id}",
				"starred_url":"https://api.github.com/users/SleeeepyZhou/starred{/owner}{/repo}",
				"subscriptions_url":"https://api.github.com/users/SleeeepyZhou/subscriptions",
				"organizations_url":"https://api.github.com/users/SleeeepyZhou/orgs",
				"repos_url":"https://api.github.com/users/SleeeepyZhou/repos",
				"events_url":"https://api.github.com/users/SleeeepyZhou/events{/privacy}",
				"received_events_url":"https://api.github.com/users/SleeeepyZhou/received_events",
				"type":"User",
				"site_admin":false
						},
			"content_type":"application/x-zip-compressed",
			"state":"uploaded",
			"size":18367993,
			"download_count":3,
			"created_at":"2024-09-22T07:14:53Z",
			"updated_at":"2024-09-22T07:14:57Z",
			"browser_download_url":"https://github.com/SleeeepyZhou/VLMCaption-TagCraft/releases/download/V0.2.9-Beta/TagCraft.winV0.2.9-beta_x86_64.zip"
		}
			],
	"tarball_url":"https://api.github.com/repos/SleeeepyZhou/VLMCaption-TagCraft/tarball/V0.2.9-Beta",
	"zipball_url":"https://api.github.com/repos/SleeeepyZhou/VLMCaption-TagCraft/zipball/V0.2.9-Beta",
	"body":"**Full Changelog**: https://github.com/SleeeepyZhou/VLMCaption-TagCraft/compare/V0.2.5-Beta...V0.2.9-Beta"
}
'''
