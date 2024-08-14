extends ScrollContainer

var path : String = "":
	set(image_file):
		path = image_file
		print(path)
		$Box/Box/Filename.text = image_file.get_file()
		var image = Image.load_from_file(image_file)
		$Box/Box/Image.texture = ImageTexture.create_from_image(image)
		full_path = image_file.get_basename() + ".txt"
		if FileAccess.file_exists(full_path):
			caption = FileAccess.get_file_as_string(full_path)
		$Box/Box/ColorBox.visible = true
		$Box/Box/Filename.visible = true
		$Box/Box/Label.visible = true
		$Box/Box/Caption.visible = true
		$Box/Box/Edit.visible = true

var caption : String = "":
	set(text):
		$Box/Box/Caption.text = text
		caption = text

var full_path : String

func _on_edit_button_up():
	var newcaption : String = $Box/Box/Caption.text
	var save_file = FileAccess.open(full_path, FileAccess.WRITE)
	save_file.store_string(newcaption)
	save_file.close()
