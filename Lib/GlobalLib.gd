extends Node

# 线程池
var maxhttp : int = 10
var is_run : bool = false

# 用户存档
const SAVEPATH = "user://data.save"

func reset():
	var access = DirAccess.open(SAVEPATH.get_base_dir())
	access.remove(SAVEPATH)

func zerojson():
	var zero_data = {
				"userpath" : [],
				"setting" : {},
				"preset" : {}, 
				"api" : {
					"gpt-4o-2024-08-06" : [true, "https://api.openai.com/v1/chat/completions", ""],
					"local" : [false, "http://127.0.0.1:8000/v1/chat/completions", ""]
						},
				"prompt" : ["Describe this image in a very detailed manner."],
				"format" : {}
					}
	var json_string = JSON.stringify(zero_data)
	var save_data = FileAccess.open(SAVEPATH, FileAccess.WRITE)
	save_data.store_string(json_string)
	save_data.close()

func readjson():
	if FileAccess.file_exists(SAVEPATH):
		var json_string = FileAccess.open(SAVEPATH, FileAccess.READ).get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			return
		var save_data = json.get_data()
		return save_data
	else:
		zerojson()
		var save_data = readjson()
		return save_data

# 图片、提示词
const IMAGE_TYPE = ["JPG", "PNG", "BMP", "GIF", "TIF", "TIFF", "JPEG", "WEBP"]
var REG : String = "[,.\\w\\s-]+"

func zip_image(path : String, quality : String, custom : int = 0) -> Image:
	var image = Image.load_from_file(path)
	var width = image.get_size().x
	var height = image.get_size().y
	
	var target : int = 512
	var aspect_ratio : float = float(width) / height
	var new_width = width
	var new_height = height
	if quality == "custom":
		target = custom
	elif quality == "high":
		target = 1024
	elif quality == "low":
		target = 512
	elif quality == "auto":
		if width >= 1024 or height >= 1024:
			target = 1024
	if custom > 0 and (width < target or height < target):
		if width < height:
			new_width = target
			new_height = int(new_width / aspect_ratio)
		else:
			new_height = target
			new_width = int(new_height * aspect_ratio)
	elif width > target or height > target:
		if width > height:
			new_width = target
			new_height = int(new_width / aspect_ratio)
		else:
			new_height = target
			new_width = int(new_height * aspect_ratio)
	image.resize(new_width, new_height)
	return image

func image_to_base64(path : String, quality : String) -> String:
	var image = zip_image(path, quality)
	return Marshalls.raw_to_base64(image.save_jpg_to_buffer(0.90))

func addition_prompt(text : String, image_path : String) -> String: # 提示词，图片路径
	if '{' not in text or '}' not in text:
		return text
	var file_name = image_path.get_file().rstrip("." + image_path.get_extension()) + ".txt"
	var dir_path = text.substr(text.find("{")+1, text.find("}")-text.find("{")-1)
	var full_path = (dir_path + "/" + file_name).simplify_path()
	var file = FileAccess.open(full_path, FileAccess.READ)
	var file_content := ""
	if file:
		file_content = file.get_as_text()
		file.close()
	return text.replace("{" + dir_path + "}", file_content)

func remove_pic(pic_path : String):
	var remove_path = (pic_path.get_base_dir() + "/Remove").simplify_path()
	var dir = DirAccess.open(pic_path.get_base_dir())
	if dir and !dir.dir_exists(remove_path):
		dir.make_dir(remove_path)
	dir.rename(pic_path, (remove_path+"/"+pic_path.get_file()).simplify_path())
	var txt_path = pic_path.get_basename() + ".txt"
	if FileAccess.file_exists(txt_path):
		dir.rename(txt_path, (remove_path+"/"+txt_path.get_file()).simplify_path())

# 停用词

const stopwords = ["i", "me", "my", "myself", "we", "our", "ours", "ourselves", "you", 
			"your", "yours", "yourself", "yourselves", "he", "him", "his", "himself", 
			"she", "her", "hers", "herself", "it", "its", "itself", "they", "them", 
			"their", "theirs", "themselves", "what", "which", "who", "whom", "this", 
			"that", "these", "those", "am", "is", "are", "was", "were", "be", "been", 
			"being", "have", "has", "had", "having", "do", "does", "did", "doing", "a", 
			"an", "the", "and", "but", "if", "or", "because", "as", "until", "while", 
			"of", "at", "by", "for", "with", "about", "against", "between", "into", 
			"through", "during", "before", "after", "above", "below", "to", "from", 
			"up", "down", "in", "out", "on", "off", "over", "under", "again", "further", 
			"then", "once", "here", "there", "when", "where", "why", "how", "all", 
			"any", "both", "each", "few", "more", "most", "other", "some", "such", 
			"no", "nor", "not", "only", "own", "same", "so", "than", "too", "very", 
			"s", "t", "can", "will", "just", "don", "should", "now"]
const regex_word = "\b(i|me|my|myself|we|our|ours|ourselves|you|your|yours|yourself|yourselves|
			he|him|his|himself|she|her|hers|herself|it|its|itself|they|them|their|theirs|themselves|
			what|which|who|whom|this|that|these|those|am|is|are|was|were|be|been|being|have|has|had|
			having|do|does|did|doing|a|an|the|and|but|if|or|because|as|until|while|of|at|by|for|with|
			about|against|between|into|through|during|before|after|above|below|to|from|up|down|
			in|out|on|off|over|under|again|further|then|once|here|there|when|where|why|how|all|
			any|both|each|few|more|most|other|some|such|no|nor|not|only|own|same|so|than|too|very|
			s|t|can|will|just|don|should|now)\b"
const stopword_use = ["i", "me", "my", "myself", "we", "our", "ours", "ourselves", "you", 
			"your", "yours", "yourself", "yourselves", "he", "him", "his", "himself", 
			"she", "her", "hers", "herself", "it", "its", "itself", "they", "them", 
			"their", "theirs", "themselves", "what", "which", "who", "whom", "this", 
			"that", "these", "those", "am", "is", "are", "was", "were", "be", "been", 
			"being", "have", "has", "had", "having", "do", "does", "did", "doing", "a", 
			"an", "the", "and", "but", "if", "or", "because", "as", "until", "while", 
			"of", "for", "with", "about", "into", "through", "during", "before", "after", 
			"to", "from", "off", "over", "under", "again", "further", "then", "once", "here", 
			"there", "when", "where", "why", "how", "all", "any", "both", "each", "few", 
			"more", "most", "other", "some", "such", "no", "nor", "not", "only", "own", 
			"same", "so", "than", "too", "very", "s", "t", "can", "will", "just", "don", 
			"should", "now"]

func remove_stopword(caption : String) -> String:
	var temp = caption.split(" ", false)
	for i in range(temp.size()):
		if stopword_use.has(temp[i]):
			temp.remove_at(i)
	return " ".join(temp)