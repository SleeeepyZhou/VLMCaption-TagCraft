extends VBoxContainer

func _ready():
	if !FileAccess.file_exists(Global.SAVEPATH):
		Global.zerojson()
	updata_list()

# 链接跳转
func _on_thank_meta_clicked(meta):
	OS.shell_open(meta)

# 提示词存储
func updata_list():
	$PromptSave/PromptList.clear()
	var list = Global.readjson()["prompt"]
	for prompt in list:
		$PromptSave/PromptList.add_item(prompt)
func _prompt_save_pressed():
	var dir = Global.readjson()
	dir["prompt"].append($Prompt.text)
	var save_file = FileAccess.open(Global.SAVEPATH, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(dir))
	save_file.close()
	updata_list()
func _prompt_delete_pressed():
	var dir = Global.readjson()
	dir["prompt"].erase($PromptSave/PromptList.text)
	var save_file = FileAccess.open(Global.SAVEPATH, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(dir))
	save_file.close()
	updata_list()
func _prompt_load_pressed():
	$Prompt.text = $PromptSave/PromptList.text

# 软件设置
func _on_setting_pressed():
	# 背景设置
	var background : String = ($"Tab/Config/API Config/Setting/Setting/Background/Backpath".text).simplify_path()
	var _extension = background.get_extension()
	if !Global.IMAGE_TYPE.has(_extension.to_upper()):
		return
	var image = Image.load_from_file(background)
	image.save_jpg("user://" + "background" + _extension, 0.9)
	$"../../../Background".texture = ImageTexture.create_from_image(image)
	
	# 存储设置
	var dir = Global.readjson()
	
	if dir["setting"].has("background"):
		var access = DirAccess.open(Global.SAVEPATH.get_base_dir())
		access.remove(dir["setting"]["background"])
	else:
		dir["setting"]["background"] = "user://" + "background" + _extension
	
	var save_data = FileAccess.open(Global.SAVEPATH, FileAccess.WRITE)
	save_data.store_string(JSON.stringify(dir))
	save_data.close()

func _on_color_color_changed(color):
	$"../../../ColorRect".color = color
	var dir = Global.readjson()
	dir["setting"]["backcolor"] = color
	var save_data = FileAccess.open(Global.SAVEPATH, FileAccess.WRITE)
	save_data.store_string(JSON.stringify(dir))
	save_data.close()
