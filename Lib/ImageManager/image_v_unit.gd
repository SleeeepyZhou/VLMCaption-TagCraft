extends HBoxContainer

var path : String = "":
	set(image_file):
		path = image_file
		$Box/ImageName.text = image_file.get_file()
		$Box/Path.text = image_file.get_base_dir()
		var image = Image.load_from_file(image_file)
		$Texture.texture = ImageTexture.create_from_image(image)

signal check(path : String)
func _on_read_pressed():
	emit_signal("check", path)
