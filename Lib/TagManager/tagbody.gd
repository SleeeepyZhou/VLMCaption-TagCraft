extends RigidBody2D

var text_rect : Vector2

func take_texture(fontsize : int = 50, intext : String = "none"):
	# 获取文本图像信息
	$TagTexture/Box/Text.text = intext
	$TagTexture/Box/Text.add_theme_font_size_override("font_size", fontsize)
	text_rect = $TagTexture/Box/Text.get_size()
	$TagTexture/Box.size = text_rect
	$TagTexture.size = text_rect
	
	# 设定各参数
	$Sprite2D.texture = $TagTexture.get_texture()
	var shape = RectangleShape2D.new()
	shape.size = text_rect
	$CollisionShape2D.shape = shape
	mass = float(fontsize) / 2
