extends MarginContainer

const Keyborad = [preload("res://Resources/Input/1.png"),preload("res://Resources/Input/2.png"),
			preload("res://Resources/Input/3.png"),preload("res://Resources/Input/4.png"),
			preload("res://Resources/Input/5.png"),preload("res://Resources/Input/6.png"),
			preload("res://Resources/Input/7.png"),preload("res://Resources/Input/8.png"),
			preload("res://Resources/Input/9.png"),]
const Xbox = [preload("res://Resources/Input/X.png"),preload("res://Resources/Input/Y.png"),
			preload("res://Resources/Input/A.png"),preload("res://Resources/Input/B.png"),
			preload("res://Resources/Input/Dpad_Left.png"),preload("res://Resources/Input/Dpad_UP.png"),
			preload("res://Resources/Input/Dpad_Right.png"),preload("res://Resources/Input/Dpad_Down.png"),]
const PS = [preload("res://Resources/Input/PS.png"),preload("res://Resources/Input/PA.png"),
			preload("res://Resources/Input/PX.png"),preload("res://Resources/Input/PO.png"),
			preload("res://Resources/Input/Dpad_Left.png"),preload("res://Resources/Input/Dpad_UP.png"),
			preload("res://Resources/Input/Dpad_Right.png"),preload("res://Resources/Input/Dpad_Down.png"),]

const OnehandL = [preload("res://Resources/Input/Dpad_Left.png"),preload("res://Resources/Input/Dpad_UP.png"),
			preload("res://Resources/Input/Dpad_Right.png"),preload("res://Resources/Input/Dpad_Down.png"),]

const EINSTEIN = preload("res://Resources/Einstein01.jpg")
var path : String = "":
	set(image_file):
		path = image_file
		if image_file.is_empty():
			$Box/Pic.texture = EINSTEIN
			remove = true
			$Tip.visible = true
		else:
			remove = false
			var image = Image.load_from_file(path)
			$Box/Pic.texture = ImageTexture.create_from_image(image)
			$Tip.visible = false
		pic_rota = $Box/Pic.texture.get_size().x / $Box/Pic.texture.get_size().y

var list_index : int

var pic_rota : float

var onehand : bool:
	set(b):
		onehand = b
		var key : Array = Keyborad
		if b:
			key = OnehandL
		$Box/ButtonBox/Texture/Key.texture = key[get_index()]
		if get_index() == 8:
			return
		$Box/ButtonBox/Texture/Xbox.texture = Xbox[get_index()]
		if get_index() > 3:
			return
		$Box/ButtonBox/Texture/PS.texture = PS[get_index()]

var remove : bool:
	set(b):
		$Recover.visible = b
	get:
		return $Recover.visible

func _ready():
	onehand = false

func _input(event):
	if event and (event.is_action_pressed("idx_" + str(get_index())) or \
			(onehand and event.is_action_pressed("idx_" + str(get_index() + 4)))):
		_on_button_pressed()

func _on_button_pressed():
	$Recover.visible = !$Recover.visible
