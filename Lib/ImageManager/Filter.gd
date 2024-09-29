extends MarginContainer

func _ready():
	update_num()
	get_viewport().size_changed.connect(re_size)

func re_size():
	position = Vector2.ZERO
	size = get_window().size
	if !current_list.is_empty():
		update_size()

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

func _on_close_pressed():
	for child in $Filter/Box/PicBox.get_children():
		child.visible = false
	$Filter/PathBox/Close.disabled = true

func _on_enter_pressed():
	if !open_path(file_path):
		$Filter/PathBox/Path.text = "Error accessing path."
		return
	$Filter/PathBox/Close.disabled = false

func _on_num_item_selected(_index):
	read_pic()

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

func _input(event):
	if event:
		if (event.is_action_pressed("filter_next") or 
				(mod != 2 and event.is_action_pressed("filter_R1")) or 
				(mod == 2 and event.is_action_pressed("filter_L2"))):
			remove()
			current_idx += clampi(current_list.size() - 1 - current_idx, 0, visNum)
			current_idx = clampi(current_idx, -1, current_list.size() - 2)
			read_pic()
		elif (event.is_action_pressed("filter_pre") or 
				(mod != 2 and event.is_action_pressed("filter_L2")) or 
				(mod == 2 and event.is_action_pressed("filter_R1"))):
			remove()
			current_idx -= clampi(current_idx + 1, 0, visNum)
			current_idx = clampi(current_idx, -1, current_list.size() - 2)
			read_pic()

func remove():
	for child in $Filter/Box/PicBox.get_children():
		if child.visible and child.remove and !child.path.is_empty():
			current_list[child.list_index] = ""
			Global.remove_pic(child.path)

func read_pic():
	for child in $Filter/Box/PicBox.get_children():
		child.visible = false
	var next_pic : int = clampi(current_list.size() - 1 - current_idx, 1, visNum)
	for i in range(next_pic):
		var unit = $Filter/Box/PicBox.get_child(i)
		unit.visible = true
		unit.path = current_list[current_idx + 1 + i]
		unit.list_index = current_idx + 1 + i
		unit.onehand = (mod == 2)
	update_size()

func update_size():
	var box_size : Vector2 = Vector2(get_window().size - Vector2i(80, 80))
	box_size.y -= ($Filter/TipBox.size.y + $Filter/PathBox.size.y)
	
	var ratio : Array[float] = []
	for child in $Filter/Box/PicBox.get_children():
		child.custom_minimum_size = Vector2.ZERO
		if child.visible:
			ratio.append(child.pic_rota)
	
	var ok = false
	var v : int = 0
	var x_pos : Array = []
	while !ok:
		v += 1
		x_pos = ratio.map(func(i): return i*(box_size.y/float(v)-90.0))
		var pos : float = 0
		var current_v : int = 1
		for i in range(x_pos.size()):
			var f : float = x_pos[i]
			pos += f
			if pos > box_size.x:
				current_v += 1
				pos = f
				if current_v > v:
					break
			elif i + 1 == x_pos.size() and pos <= box_size.x:
				ok = true
	
	for child in $Filter/Box/PicBox.get_children():
		if child.is_visible():
			child.set_custom_minimum_size(Vector2(0, box_size.y/float(v)))

