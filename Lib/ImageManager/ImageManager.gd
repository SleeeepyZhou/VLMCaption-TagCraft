extends HSplitContainer

func _on_thank_meta_clicked(meta):
	OS.shell_open(meta)

func _on_path_text_changed(new_text):
	pass # Replace with function body.

func _on_enter_pressed():
	pass # Replace with function body.

func _on_show_mod_item_selected(index):
	pass # Replace with function body.

func _on_backpath_text_changed(new_text):
	pass # Replace with function body.

func _on_set_color_color_changed(color):
	pass # Replace with function body.

func _on_set_back_button_up():
	$FileShow/Backpic
	$FileShow/Background

const v_unit = "res://Lib/ImageManager/image_v_unit.tscn"
const h_unit = "res://Lib/ImageManager/image_#_unit.tscn"
