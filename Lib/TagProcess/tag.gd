extends HBoxContainer

@onready var tag = $Tag
@onready var times = $Times

var path : String
var image_file : PackedStringArray

const Translator = "res://Lib/TagProcess/Translator.tscn"
func translate(translator : int):
	if tag.text.is_empty():
		return
	var temp = load(Translator)
	var trans = temp.instantiate()
	add_child(trans)
	var translation : String
	if translator == 0:
		var dir = Global.readjson()
		var key = dir["api"]["gpt-4o"][2]
		translation = await trans.gpt_translator(tag.text, key)
	else:
		translation = await trans.chinese_translator(tag.text)
	$Translation.text = translation

func _on_remove_button_up():
	var old_tag : String = $Tag.text
	# 修改所有文件
	for file in image_file:
		var image_path : String = (path+"/"+file).simplify_path()
		var full_path : String = image_path.get_basename() + ".txt"
		var caption : String = FileAccess.get_file_as_string(full_path)
		var temp : PackedStringArray = caption.split(",", false)
		var pos : int = 0
		for i in range(temp.size()):
			if temp[i] in old_tag:
				pos = i
				break
		temp.remove_at(pos)
		var new_caption = ", ".join(temp)
		var save_file = FileAccess.open(full_path, FileAccess.WRITE)
		save_file.store_string(new_caption)
		save_file.close()
	
	# 生成词云
	var box = $"../../../../../.."
	box.cloud_table.erase(old_tag)
	box.word_cloud()
	
	queue_free()

func _on_replace_button_up():
	var new_tag : String = $Newtag.text
	var old_tag : String = $Tag.text
	# 修改所有文件
	for file in image_file:
		var image_path : String = (path+"/"+file).simplify_path()
		var full_path : String = image_path.get_basename() + ".txt"
		var caption : String = FileAccess.get_file_as_string(full_path)
		var temp : PackedStringArray = caption.split(",", false)
		var pos : int = 0
		for i in range(temp.size()):
			if temp[i] in $Tag.text:
				pos = i
				break
		temp.set(pos, new_tag)
		var new_caption = ", ".join(temp)
		var save_file = FileAccess.open(full_path, FileAccess.WRITE)
		save_file.store_string(new_caption)
		save_file.close()
	
	# 生成词云
	var box = $"../../../../../.."
	var id = box.cloud_table.erase(old_tag)
	if id:
		box.cloud_table[new_tag] = int($Times.text)
		box.word_cloud()
	
	$Tag.text = new_tag
	$Newtag.text = ""

