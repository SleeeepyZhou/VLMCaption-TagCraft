extends HBoxContainer

var tag : String = "":
	get:
		tag = $Tag.text
		return tag
	set(text):
		tag = text
		$Tag.text = text

var path : String
var image_file : String

const Translator = "res://Lib/TagManager/Translator.tscn"
func translate():
	if tag.is_empty():
		return
	var temp = load(Translator)
	var trans = temp.instantiate()
	add_child(trans)
	var translation : String = await trans.chinese_translator(tag)
	$Translation.text = translation

func _on_remove_button_up():
	var old_tag : String = tag
	var caption : String = FileAccess.get_file_as_string(path)
	var temp : PackedStringArray = caption.split(",", false)
	var pos : int = 0
	for i in range(temp.size()):
		if temp[i] in old_tag:
			pos = i
			break
	temp.remove_at(pos)
	var new_caption = ", ".join(temp)
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	save_file.store_string(new_caption)
	save_file.close()

func _on_replace_button_up():
	var new_tag : String = $Newtag.text
	var old_tag : String = tag
	var caption : String = FileAccess.get_file_as_string(path)
	var temp : PackedStringArray = caption.split(",", false)
	var pos : int = 0
	for i in range(temp.size()):
		if temp[i] in old_tag:
			pos = i
			break
	temp.set(pos, new_tag)
	var new_caption = ", ".join(temp)
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	save_file.store_string(new_caption)
	save_file.close()
