extends MarginContainer

func _ready():
	get_viewport().files_dropped.connect(on_files_dropped) # 文件拖拽信号

# 图片放入
var single_path : String = ""

func on_files_dropped(files):
	var path : String = files[0]
	if Global.IMAGE_TYPE.has(path.get_extension().to_upper()) and visible:
		var image = Image.load_from_file(path)
		$SingleImage/UpOut/ImageUp/Label.visible = false
		$SingleImage/UpOut/ImageUp.texture = ImageTexture.create_from_image(image)
		single_path = path

func _on_caption_button_up():
	$SingleImage/UpOut/Output.text = "Processing..."
	$SingleImage/UpOut/Output.text = await %ApiUtils.run_api(single_path)
	Global.is_run = false

func _on_line_edit_text_submitted(new_text):
	var path : String = new_text
	if !path.get_extension().is_empty() and Global.IMAGE_TYPE.has(\
			path.get_extension().to_upper()) and visible:
		var image = Image.load_from_file(path)
		$SingleImage/UpOut/ImageUp/LineEdit.position.y = 0
		$SingleImage/UpOut/ImageUp/Label.visible = false
		$SingleImage/UpOut/ImageUp.texture = ImageTexture.create_from_image(image)
		single_path = path
