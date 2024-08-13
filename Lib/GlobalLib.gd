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
	var prompt1 : String = "As an AI image tagging expert, please provide precise tags for these images to enhance CLIP model's understanding of the content. Employ succinct keywords or phrases, steering clear of elaborate sentences and extraneous conjunctions. Prioritize the tags by relevance. Your tags should capture key elements such as the main subject, setting, artistic style, composition, image quality, color tone, filter, and camera specifications, and any other tags crucial for the image. When tagging photos of people, include specific details like gender, nationality, attire, actions, pose, expressions, accessories, makeup, composition type, age, etc. For other image categories, apply appropriate and common descriptive tags as well. Recognize and tag any celebrities, well-known landmark or IPs if clearly featured in the image. Your tags should be accurate, non-duplicative, and within a 20-75 word count range. These tags will use for image re-creation, so the closer the resemblance to the original image, the better the tag quality. Tags should be comma-separated. Exceptional tagging will be rewarded with $10 per image."
	var zero_data = {
				"userpath" : [],
				"setting" : {},
				"preset" : {}, 
				"api" : {
					"gpt-4o" : [true, "https://api.openai.com/v1/chat/completions", ""],
					"local" : [false, "http://127.0.0.1:8000/v1/chat/completions", ""]
						},
				"prompt" : [prompt1, "Describe this image in a very detailed manner."],
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
const IMAGE_TYPE = ["jpg", "png", "bmp", "gif", "tif", "tiff", "jpeg", "webp"]

func zip_image(path : String, quality : String) -> Image:
	var image = Image.load_from_file(path)
	var target : int = 1024
	var width = image.get_size().x
	var height = image.get_size().y
	if quality:
		if quality == "high":
			target = 1024
		elif quality == "low":
			target = 512
		elif quality == "auto":
			if width >= 1024 or height >= 1024:
				target = 1024
			else:
				target = 512
	var aspect_ratio : float = float(width) / height
	var new_width = width
	var new_height = height
	if width > target or height > target:
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
	return Marshalls.raw_to_base64(image.save_jpg_to_buffer(1))

func addition_prompt(text : String, image_path : String) -> String: # 提示词，图片路径
	if '{' not in text and '}' not in text:
		return text
	var file_name = image_path.get_file().rstrip("." + image_path.get_extension()) + ".txt"
	var dir_path = text.substr(text.find("{")+1, text.find("}")-text.find("{")-1)
	var full_path = (dir_path + "/" + file_name).simplify_path()
	var file = FileAccess.open(full_path, FileAccess.READ)
	var file_content := ""
	if file:
		file_content = file.get_as_text()
		file.close()
	else:
		return "Error reading file: Could not open file."
	return text.replace("{" + dir_path + "}", file_content)
