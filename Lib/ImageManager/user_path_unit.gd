extends HBoxContainer

var path : String = "":
	set(text):
		$Box/Box/Path.text = text
		$Box/Label.text = text.get_file()
		path = text

func _on_remove_button_up():
	var fi = Global.readjson()
	fi["userpath"].erase(path)
	var save_file = FileAccess.open(Global.SAVEPATH, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(fi))
	save_file.close()
	queue_free()

signal send(path : String)
func _on_open_pressed():
	emit_signal("send", path)
