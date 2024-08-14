extends MarginContainer

func _on_run_button_up():
	var image_path : String = ($"Failed File Screening/FailedPath".text).simplify_path()
	var key : String = $"Failed File Screening/Keywords".text
	if key.is_empty():
		key = "Error:"
	var dir = DirAccess.open(image_path)
	if dir and dir.make_dir("Error_files") == OK:
		$"Failed File Screening/Output/ScriptOutput".text = "Processing"
		var taget_path : String = (image_path+"/Error_files").simplify_path()
		var templist = dir.get_files()
		var count : int = 0
		for file in templist:
			if Global.IMAGE_TYPE.has(file.get_extension().to_upper()):
				var image_file : String = (image_path+"/"+file).simplify_path()
				var full_path : String = image_file.get_basename() + ".txt"
				if FileAccess.file_exists(full_path):
					var original : String = FileAccess.get_file_as_string(full_path)
					if key in original:
						dir.rename(image_file, (taget_path+"/"+file).simplify_path())
						dir.rename(full_path, (taget_path+"/"+file+".txt").simplify_path())
						count += 1
		$"Failed File Screening/Output/ScriptOutput".text = "Processed " + str(count) \
															+ " images to /Error_files"
	else:
		$"Failed File Screening/Output/ScriptOutput".text = "Error accessing path."
