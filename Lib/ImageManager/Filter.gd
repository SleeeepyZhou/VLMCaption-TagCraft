extends MarginContainer

func _ready():
	update_num()
	get_viewport().size_changed.connect(re_size)

func re_size():
	position = Vector2.ZERO
	size = get_window().size
	read_pic()

func _on_help_pressed():
	$Filter/Box/TipBox.visible = !$Filter/Box/TipBox.visible

func _on_mode_item_selected(_index):
	update_num()

func update_num():
	$Filter/TipBox/Num.clear()
	var l : int = 1
	#var l : int = 9
	#if mod == 0:
		#l = 9
	#elif mod == 1:
		#l = 8
	#elif mod == 2:
		#l = 4
	for i in range(l):
		$Filter/TipBox/Num.add_item(str(i+1))

func _on_close_pressed():
	for child in $Filter/Box/PicBox.get_children():
		child.visible = false
	$Filter/PathBox/Close.disabled = true

func _on_enter_pressed():
	if !open_path(file_path):
		$Filter/PathBox/Path.text = "Error accessing path."
		return
	$Filter/PathBox/Close.disabled = false

var file_path : String:
	set(t):
		$Filter/PathBox/Path.text = t
		_on_enter_pressed()
	get:
		return $Filter/PathBox/Path.text

var mod : int:
	get:
		return $Filter/TipBox/Mode.selected
var visNum : int:
	get:
		return $Filter/TipBox/Num.selected + 1

var current_idx : int = -1
var current_list : Array = []
func open_path(path : String) -> bool:
	var dir = DirAccess.open(path)
	if dir:
		var templist = dir.get_files()
		current_list = []
		current_idx = -1
		for file in templist:
			if Global.IMAGE_TYPE.has(file.get_extension().to_upper()):
				var image_file : String = (path + "/" + file).simplify_path()
				current_list.append(image_file)
		read_pic()
		return true
	else:
		return false

func read_pic():
	for child in $Filter/Box/PicBox.get_children():
		child.custom_minimum_size = Vector2.ZERO
		child.queue_redraw()
		child.visible = false
	var next_pic : int = clampi(current_list.size() - 1 - current_idx, 0, visNum)
	var unit_size : Vector2 = get_window().size - Vector2i(80, 200)
	if next_pic > 6:
		unit_size /= 3
	elif next_pic > 3:
		unit_size /= 2
	unit_size.x /= next_pic
	for i in range(next_pic):
		var unit = $Filter/Box/PicBox.get_child(i)
		unit.visible = true
		unit.custom_minimum_size = unit_size
		#while !unit.vis.is_on_screen():
			#for child in $Filter/Box/PicBox.get_children():
				#child.custom_minimum_size -= Vector2(10, 10)
		unit.path = current_list[current_idx + 1 + i]
		unit.onehand = (mod == 2)

func _input(event):
	if event and event.is_action_pressed("filter_next"):
		pass
