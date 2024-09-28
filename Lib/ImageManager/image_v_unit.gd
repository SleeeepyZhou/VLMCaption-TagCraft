extends HBoxContainer

var path : String = "":
	set(image_file):
		path = image_file
		$Box/ImageName.text = image_file.get_file()
		$Box/Path.text = image_file.get_base_dir()
		var image = Image.load_from_file(image_file)
		$Texture.texture = ImageTexture.create_from_image(image)

signal check(path : String , idx : int)
func _on_read_pressed():
	emit_signal("check", path, get_index())
	if $"..".get_child_count() - 1 > get_index():
		var next = $"..".get_child(get_index() + 1).get_path()
		focus_neighbor_bottom = next
		focus_neighbor_right = next
		focus_next = next
	if get_index() != 0:
		var pre = $"..".get_child(get_index() - 1).get_path()
		focus_neighbor_left = pre
		focus_neighbor_top = pre
		focus_previous = pre

@onready var vis = $Visible
