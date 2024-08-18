extends ScrollContainer

var path : String = "":
	set(image_file):
		path = image_file
		$Box/Box/Filename.text = image_file.get_file()
		var image = Image.load_from_file(image_file)
		$Box/Box/Box/Image.texture = ImageTexture.create_from_image(image)
		full_path = image_file.get_basename() + ".txt"
		if FileAccess.file_exists(full_path):
			caption = FileAccess.get_file_as_string(full_path)
		else:
			caption = ""
		$Box/Box/ColorBox.visible = true
		$Box/Box/Filename.visible = true
		$Box/Box/TipBox.visible = true
		$Box/Box/Caption.visible = true
		$Box/Box/ButtonBox.visible = true

var caption : String = "":
	set(text):
		$Box/Box/Caption.text = text # 请不要乱动Caption节点的minimum size，会发生不可预知的bug
		caption = text

var full_path : String

func _on_edit_button_up():
	var newcaption : String = $Box/Box/Caption.text
	var save_file = FileAccess.open(full_path, FileAccess.WRITE)
	save_file.store_string(newcaption)
	save_file.close()
	$Box/Box/TipBox/Tip.text = "Edit complete."

func _on_captioner_button_up():
	%ApiUtils.batchmod = true
	$Box/Box/TipBox/Tip.text = "Processing..."
	%ApiUtils.lock_input(true)
	
	var new_caption : String = await %ApiUtils.run_api(path)
	var original : String = ""
	if FileAccess.file_exists(full_path):
		original = FileAccess.get_file_as_string(full_path)
	caption = new_caption + ", " + original
	var save_file = FileAccess.open(full_path, FileAccess.WRITE)
	save_file.store_string(caption)
	save_file.close()
	
	%ApiUtils.batchmod = false
	%ApiUtils.lock_input(false)
	Global.is_run = false
	$Box/Box/TipBox/Tip.text = "Processing complete."
	await get_tree().create_timer(1).timeout
	$Box/Box/TipBox/Tip.text = "Remember set API in captioner"

var image_index : int
func _input(event):
	if $"..".visible:
		if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
			image_index = clampi(image_index + 1, 0, $"../..".image_count - 1)
			if $"../Image/Image#Box".visible:
				path = $"../Image/Image#Box/Box".get_child(image_index).path
			elif $"../Image/ImageVBox".visible:
				path = $"../Image/ImageVBox/Box".get_child(image_index).path
		elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
			image_index = clampi(image_index - 1, 0, $"../..".image_count - 1)
			if $"../Image/Image#Box".visible:
				path = $"../Image/Image#Box/Box".get_child(image_index).path
			elif $"../Image/ImageVBox".visible:
				path = $"../Image/ImageVBox/Box".get_child(image_index).path
