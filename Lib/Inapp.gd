extends Control

var pre_theme : Theme = preload("res://Resources/main_theme.tres")
var fontsize : int = 20

func _ready():
	get_viewport().size_changed.connect(resize)
	pre_theme.default_font_size = fontsize
	var setting = Global.readjson()["setting"]
	if setting.has("background"):
		var image = Image.load_from_file(setting["background"])
		$Background.texture = ImageTexture.create_from_image(image)
	if setting.has("backcolor"):
		$ColorRect.color = setting["backcolor"]

func resize():
	fontsize = round(20.0 * (get_viewport_rect().size.length() / Vector2(1800,1080).length()))
	size = get_viewport_rect().size
	$Background.set_size(size)
	$Captioner.set_size(size)
	%Editbox.set_size(size)
	pre_theme.default_font_size = fontsize

func _on_gocaption_pressed():
	$Captioner.visible = true
	$ImageManager.visible = false

func _on_gomanager_pressed():
	$Captioner.visible = false
	$ImageManager.visible = true

