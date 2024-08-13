extends MarginContainer

var started := false

func _on_run_button_up():
	started = true
	var image_path : String = $"Batch Image/InputPath/Path".text
	var mode : int = $"Batch Image/HandlingMode/Mode".selected
	var dir = DirAccess.open(image_path)
	if dir:
		%ApiUtils.batchmod = true
		var templist = dir.get_files()
		$"Batch Image/Output".text = "Processing..."
		%ApiUtils.lock_input(true)
		for file in templist:
			if !started:
				Global.is_run = false
				%ApiUtils.batchmod = false
				return
			if Global.IMAGE_TYPE.has(file.get_extension()):
				var image_file : String = (image_path + "/" + file).simplify_path()
				var full_path : String = image_file.get_basename() + ".txt"
				if mode == 3 and FileAccess.file_exists(full_path):
					continue
				else:
					var caption : String = await %ApiUtils.run_api(image_file)
					var original : String = ""
					if FileAccess.file_exists(full_path):
						original = FileAccess.get_file_as_string(full_path)
					if mode == 1:
						caption = caption + original
					elif mode == 2:
						caption = original + caption
					var save_file = FileAccess.open(full_path, FileAccess.WRITE)
					save_file.store_string(caption)
					save_file.close()
		$"Batch Image/Output".text = "Batch processing complete. Captions \
								saved or updated as '.txt' files next to images."
		%ApiUtils.batchmod = false
		%ApiUtils.lock_input(false)
	else:
		$"Batch Image/Output".text = "Error accessing path."
	started = false
	Global.is_run = false

func _on_stop_button_up():
	%ApiUtils.lock_input(false)
	if started:
		started = false
		$"Batch Image/Output".text = "Attempting to stop batch processing.\
				 Please wait for the current image to finish."
