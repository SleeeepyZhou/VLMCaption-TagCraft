extends MarginContainer

func _ready():
	update_num()

func _on_help_pressed():
	$Filter/Box/TipBox.visible = !$Filter/Box/TipBox.visible

func _on_mode_item_selected(_index):
	update_num()

func update_num():
	$Filter/TipBox/Num.clear()
	var l : int = 9
	if mod == 0:
		l = 9
	elif mod == 1:
		l = 8
	elif mod == 2:
		l = 4
	for i in range(l):
		$Filter/TipBox/Num.add_item(str(i+1))

var file_path : String:
	set(t):
		$Filter/PathBox/Path.text = t
		_on_enter_pressed()
	get:
		return $Filter/PathBox/Path.text

var mod : int:
	get:
		return $Filter/TipBox/Mode.selected

func _on_close_pressed():
	for child in $Filter/Box/PicBox.get_children():
		child.queue_free()
	$Filter/TipBox/Mode.disabled = false
	$Filter/PathBox/Path.editable = true
	$Filter/PathBox/Enter.disabled = false
	$Filter/PathBox/Close.disabled = true

func _on_enter_pressed():
	$Filter/TipBox/Mode.disabled = true
	$Filter/PathBox/Path.editable = false
	$Filter/PathBox/Enter.disabled = true
	$Filter/PathBox/Close.disabled = false

func open_path(path):
	pass
