extends MarginContainer

var started := false

func _on_run_button_up():
	started = true
	Global.is_run = true
	var image_path : String = ($"Watermark Detection/PathInput/ImagePath".text).simplify_path()
	var taget_path : String = ($"Watermark Detection/PathOutput/OutPath".text).simplify_path()
	var mode : int = $"Watermark Detection/PathOutput/HandlingMode".selected
	if taget_path.is_empty():
		taget_path = (image_path + "/watermark").simplify_path()
	var dir = DirAccess.open(image_path)
	var tagetdir = DirAccess.open(taget_path)
	if !tagetdir:
		if dir.make_dir_recursive(taget_path) == OK:
			tagetdir = DirAccess.open(taget_path)
		else:
			$"Watermark Detection/Button/Output".text = "Error accessing path."
			started = false
			Global.is_run = false
			return
	if dir and tagetdir:
		var templist = dir.get_files()
		$"Watermark Detection/Button/Output".text = "Processing..."
		%ApiUtils.lock_input(true)
		var original_prompt : String = %Prompt.text
		%Prompt.text = "Is image have watermark"
		var error_count : int = 0
		var count : int = 0
		for file in templist:
			if !started:
				$"Watermark Detection/Button/Output".text = "Total checked images: "\
											+ str(count) + ". Stopped by user."
				Global.is_run = false
				return
			if Global.IMAGE_TYPE.has(file.get_extension()):
				var image_file : String = (image_path + "/" + file).simplify_path()
				var caption : String = await %ApiUtils.run_api(image_file)
				if "Error:" in caption:
					error_count += 1
					continue
				if "Yes" in caption and "EOI" not in caption:
					count += 1
					if mode == 0:
						dir.rename(image_file, (taget_path+"/"+file).simplify_path())
					else:
						dir.copy(image_file, (taget_path+"/"+file).simplify_path())
		$"Watermark Detection/Button/Output".text = "Total checked images: "\
							+ str(count) + ". " + str(error_count) + " errors"
		%Prompt.text = original_prompt
		%ApiUtils.lock_input(false)
	else:
		$"Watermark Detection/Button/Output".text = "Error accessing path."
	started = false
	Global.is_run = false

func _on_stop_button_up():
	%ApiUtils.lock_input(false)
	if started:
		started = false
		$"Watermark Detection/Button/Output".text = "Attempting to stop batch \
						processing. Please wait for the current image to finish."
