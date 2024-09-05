extends Control

func _ready():
	get_viewport().size_changed.connect(resize)
	var setting = Global.readjson()["setting"]
	if setting.has("background"):
		var image = Image.load_from_file(setting["background"])
		$Background.texture = ImageTexture.create_from_image(image)
	if setting.has("backcolor"):
		$ColorRect.color = setting["backcolor"]

func resize():
	size = get_viewport_rect().size
	$Background.set_size(size)
	$Captioner.set_size(size)
	%Editbox.set_size(size)

func _on_gocaption_pressed():
	$Captioner.visible = true
	$ImageManager.visible = false

func _on_gomanager_pressed():
	$Captioner.visible = false
	$ImageManager.visible = true
