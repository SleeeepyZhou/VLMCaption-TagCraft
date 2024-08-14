extends MarginContainer

func _ready():
	for i in range(3):
		var temp = load("res://Lib/Extra/rule.tscn")
		var new_rule = temp.instantiate()
		$"Image filtering/Box/Rollbox/Rules".add_child(new_rule)

func _on_addrule_pressed():
	var temp = load("res://Lib/Extra/rule.tscn")
	var new_rule = temp.instantiate()
	$"Image filtering/Box/Rollbox/Rules".add_child(new_rule)

var started := false
func _on_run_button_up():
	# 锁定状态
	started = true
	$"Image filtering/Button/Addrule".set_disabled(true)
	
	# 取规则表
	var rule : Dictionary = {}
	for child in $"Image filtering/Box/Rollbox/Rules".get_children():
		if child.key.is_empty():
			continue
		rule[child.key] = child.rule_mode
	
	# 信息获取
	var image_path : String = ($"Image filtering/Input/ImagePath".text).simplify_path()
	var taget_path : String = ($"Image filtering/Input/OutputPath".text).simplify_path()
	var mode : int = $"Image filtering/Button/HandlingMode".selected
	if taget_path.is_empty():
		taget_path = (image_path + "/classify_output").simplify_path()
	var dir = DirAccess.open(image_path)
	var tagetdir = DirAccess.open(taget_path)
	if !tagetdir:
		if dir.make_dir_recursive(taget_path) == OK:
			tagetdir = DirAccess.open(taget_path)
		else:
			$"Image filtering/Button/Output".text = "Error accessing path."
			started = false
			Global.is_run = false
			return
	
	# 读取文件
	if dir and tagetdir:
		$"Image filtering/Button/Output".text = "Processing..."
		%ApiUtils.lock_input(true)
		var templist = dir.get_files()
		var error_count : int = 0
		var count : int = 0
		var getted : Dictionary = {}
		# 遍历文件
		for file in templist:
			if !started:
				$"Image filtering/Button/Output".text = "Total checked images: "\
											+ str(count) + ". Stopped by user."
				Global.is_run = false
				return
			# 发现图片
			if Global.IMAGE_TYPE.has(file.get_extension().to_upper()):
				count += 1
				var image_file : String = (image_path + "/" + file).simplify_path()
				var caption : String = await %ApiUtils.run_api(image_file)
				if "Error:" in caption:
					error_count += 1
					continue
				var conform : String
				# 遍历规则
				for key in rule:
					var involve = bool(rule[key])
					if (involve and (key in caption)) or \
						(!involve and (key not in caption)):
						if conform.is_empty():
							conform = key
							continue
						conform += ", "  + key
				getted[image_file] = conform
		# 移动图片
		for file in getted:
			var new_path = (taget_path +"/"+ getted[file] +"/"+ file.get_file()).simplify_path()
			if mode == 0:
				dir.rename(file, new_path)
			else:
				dir.copy(file, new_path)
		$"Image filtering/Button/Output".text = "Total checked images: "\
							+ str(count) + ". " + str(error_count) + " errors"
		%ApiUtils.lock_input(false)
		$"Image filtering/Button/Addrule".set_disabled(false)
	else:
		$"Image filtering/Button/Output".text = "Error accessing path."
	started = false
	Global.is_run = false


func _on_stop_button_up():
	%ApiUtils.lock_input(false)
	$"Image filtering/Button/Addrule".set_disabled(false)
	if started:
		started = false
		$"Image filtering/Button/Output".text = "Attempting to stop batch \
						processing. Please wait for the current image to finish."
