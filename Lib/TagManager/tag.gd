extends HBoxContainer

var tag : String = "":
	get:
		tag = $Tag.text
		return tag
	set(text):
		tag = text
		$Tag.text = text
var times : String = "":
	get:
		times = $Times.text
		return times
	set(t):
		times = t
		$Times.text = t

var path : String
var image_file : PackedStringArray

const Translator = "res://Lib/TagManager/Translator.tscn"
func translate(translator : int):
	if tag.is_empty():
		return
	var temp = load(Translator)
	var trans = temp.instantiate()
	add_child(trans)
	var translation : String
	if translator == 0:
		var dir = Global.readjson()
		var key = dir["api"]["gpt-4o"][2]
		translation = await trans.gpt_translator(tag, key)
	else:
		translation = await trans.chinese_translator(tag)
	$Translation.text = translation

func _on_remove_button_up():
	var old_tag : String = tag
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
		var new_caption = ",".join(temp)
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
	var old_tag : String = tag
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
		temp.set(pos, new_tag)
		var new_caption = ",".join(temp)
		var save_file = FileAccess.open(full_path, FileAccess.WRITE)
		save_file.store_string(new_caption)
		save_file.close()
	
	# 生成词云
	var box = $"../../../../../.."
	var id = box.cloud_table.erase(old_tag)
	if id:
		box.cloud_table[new_tag] = int(times)
		box.word_cloud()
	
	tag = new_tag
	$Newtag.text = ""

func _on_move_pressed():
	var t_index = int($Index.value) - 1
	for file in image_file:
		var full_path : String = (path+"/"+file).simplify_path().get_basename() + ".txt"
		var caption : String = FileAccess.get_file_as_string(full_path)
		var temp : PackedStringArray = caption.split(",", false)
		temp.remove_at(temp.find(tag))
		temp.insert(clampi(t_index, 0, temp.size()), tag.dedent())
		var new_caption = ",".join(temp)
		var save_file = FileAccess.open(full_path, FileAccess.WRITE)
		save_file.store_string(new_caption)
		save_file.close()
	var outbox = $"../../../../../..".output
	outbox.text = "Tag " + tag + " is move to position " + str(t_index + 1)
