extends MarginContainer

func _on_run_zip_button_up():
	var image_path : String = $Box/Run/ImagePath.text
	var dir = DirAccess.open(image_path)
	if dir:
		$Box/OutPut/ProcessOutput.text = "Processing..."
		var templist = dir.get_files()
		for file in templist:
			if Global.IMAGE_TYPE.has(file.get_extension().to_upper()):
				var image_file : String = (image_path+"/"+file).simplify_path()
				var new_image : Image = Global.zip_image(image_file, $Box/OutPut/Qu.text,\
																 $Box/OutPut/Min.value)
				new_image.save_jpg(image_file, 0.9)
		$Box/OutPut/ProcessOutput.text = "Processed images in folder: " + image_path
	else:
		$Box/OutPut/ProcessOutput.text = "Error accessing path."

func _on_qu_item_selected(index):
	if index == 3:
		$Box/OutPut/Label3.visible = true
		$Box/OutPut/Min.visible = true
	else:
		$Box/OutPut/Label3.visible = false
		$Box/OutPut/Min.visible = false
