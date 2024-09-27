extends ScrollContainer

var full_path : String
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
		$Box/Box/ButtonBox.visible = true
		if $Box/Box/ButtonBox/CaptionMod.selected == 0:
			$Box/Box/Caption.visible = true
			$Box/Box/CaptionList.visible = false
			$Box/Box/ButtonBox/Trans.visible = false
		else:
			$Box/Box/Caption.visible = false
			$Box/Box/CaptionList.visible = true
			$Box/Box/ButtonBox/Trans.visible = true

const INFTAG = preload("res://Lib/ImageManager/Inftag.tscn")
var caption : String = "":
	set(text):
		$Box/Box/Caption.text = text # 请不要乱动Caption节点的minimum size，会发生不可预知的bug
		caption = text
		
		var temp : PackedStringArray = caption.split(",", false)
		var newtemp : PackedStringArray = []
		for temptag in temp:
			# 标准化分隔
			newtemp.append(temptag.dedent())
		for tag in $Box/Box/CaptionList.get_children():
			tag.queue_free()
		for tag in newtemp:
			var newtagbox = INFTAG.instantiate()
			newtagbox.path = full_path
			newtagbox.image_file = path
			newtagbox.tag = tag
			if $Box/Box/ButtonBox/Trans.button_pressed:
				newtagbox.translate()
			$Box/Box/CaptionList.add_child(newtagbox)

func _on_caption_mod_item_selected(index):
	if index == 0:
		$Box/Box/Caption.visible = true
		$Box/Box/CaptionList.visible = false
		$Box/Box/ButtonBox/Trans.visible = false
	else:
		$Box/Box/Caption.visible = false
		$Box/Box/CaptionList.visible = true
		$Box/Box/ButtonBox/Trans.visible = true

func _on_trans_toggled(toggled_on):
	if toggled_on:
		for tag in $Box/Box/CaptionList.get_children():
			tag.translate()

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

var currunt_box : Node:
	get:
		if $"../Image/ImageVBox".visible:
			return $"../Image/ImageVBox/Box"
		elif $"../Image/Image#Box".visible:
			return $"../Image/Image#Box/Box"
		else:
			return null

var image_index : int
#func _input(event):
	#if $"..".visible:
		#if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
			#image_index = clampi(image_index + 1, 0, $"../..".image_count - 1)
			#if currunt_box:
				#path = currunt_box.get_child(image_index).path
		#elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
			#image_index = clampi(image_index - 1, 0, $"../..".image_count - 1)
			#if currunt_box:
				#path = currunt_box.get_child(image_index).path

func _on_remove_pressed():
	Global.remove_pic(path)
	var box
	if currunt_box:
		box = currunt_box
	box.get_child(image_index).queue_free()
	$"../..".image_count = box.get_child_count()
	image_index = clampi(image_index, 0, $"../..".image_count - 1)
	path = box.get_child(image_index).path
