extends TabContainer

func _on_thank_meta_clicked(meta):
	OS.shell_open(meta)

var path_text : String = "":
	set(t):
		path_text = t
		$"../../PathBox/Path".text = t
	get:
		path_text = $"../../PathBox/Path".text
		return path_text

const USER_PATH_UNIT = preload("res://Lib/ImageManager/user_path_unit.tscn")
func update_list():
	for child in $UsePath/UsePath/UsePathBox.get_children():
		child.queue_free()
	var fi : Array = Global.readjson()["userpath"]
	for path in fi:
		var newunit = USER_PATH_UNIT.instantiate()
		$UsePath/UsePath/UsePathBox.add_child(newunit)
		newunit.path = path
		newunit.connect("send", open_path)

func _ready():
	current_tab = 0
	update_list()
	var setting = Global.readjson()["setting"]
	if setting.has("managerbackground"):
		var image = Image.load_from_file(setting["managerbackground"])
		$"../Backpic".texture = ImageTexture.create_from_image(image)
	if setting.has("managercolor"):
		$"../Background".color = setting["managercolor"]

func _on_enter_pressed():
	if path_text.is_empty():
		return
	if path_text.get_extension().is_empty() and !path_text.get_base_dir().is_empty():
		open_path(path_text)
	else:
		open_path(path_text.get_base_dir())

func show_warning(text : String):
	%ManagerWarning.text = text
	%ManagerWarning.visible = true
	await get_tree().create_timer(1).timeout
	%ManagerWarning.visible = false

func _on_set_back_button_up():
	var new_pic : String = $Setting/Settingbox/Buttunbox/Backpath.text
	var new_color = $Setting/Settingbox/Buttunbox/SetColor.color
	var dir = Global.readjson()
	$"../Background".color = new_color
	dir["setting"]["managercolor"] = new_color
	if !Global.IMAGE_TYPE.has(new_pic.get_extension().to_upper()):
		show_warning("Unsupported file format.")
	else:
		var image = Image.load_from_file(new_pic)
		var imagepath : String = "user://" + "managerbackground" + new_pic.get_extension()
		if dir["setting"].has("managerbackground"):
			var access = DirAccess.open(Global.SAVEPATH.get_base_dir())
			access.remove(dir["setting"]["managerbackground"])
		image.save_jpg(imagepath, 0.9)
		dir["setting"]["managerbackground"] = imagepath
		$"../Backpic".texture = ImageTexture.create_from_image(image)
	var save_data = FileAccess.open(Global.SAVEPATH, FileAccess.WRITE)
	save_data.store_string(JSON.stringify(dir))
	save_data.close()

const UNIT_MOD = ["res://Lib/ImageManager/image_#_unit.tscn", 
					"res://Lib/ImageManager/image_v_unit.tscn"]
@onready var IMAGE_MOD = [$"FileShow/Image/Image#Box",
						$FileShow/Image/ImageVBox]
var image_count : int = 0

var imagebox : Node:
	get:
		return IMAGE_MOD[showmod].get_node("Box")
var showmod : int:
	get:
		return $"../../PathBox/ShowMod".selected
func open_path(path : String):
	var dir = DirAccess.open(path)
	if dir:
		$"../../PathBox/Path".editable = false
		$"../../PathBox/Enter".disabled = true
		var fi = Global.readjson()
		if !fi["userpath"].has(path):
			fi["userpath"].insert(0, path)
			fi["userpath"].resize(clampi(fi["userpath"].size(), 1, 20))
			var save_file = FileAccess.open(Global.SAVEPATH, FileAccess.WRITE)
			save_file.store_string(JSON.stringify(fi))
			save_file.close()
			update_list()
		var templist = dir.get_files()
		for child in imagebox.get_children():
			child.queue_free()
		IMAGE_MOD[showmod].visible = true
		IMAGE_MOD[int(!bool(showmod))].visible = false
		end_node = null
		current_list = []
		image_count = 0
		for file in templist:
			if Global.IMAGE_TYPE.has(file.get_extension().to_upper()):
				var image_file : String = (path + "/" + file).simplify_path()
				current_list.append(image_file)
		add_imgunit()
		$BackLoad.start()
		$"../../PathBox/Path".editable = true
		$"../../PathBox/Enter".disabled = false
		path_text = path
		current_tab = 1
	else:
		var fi = Global.readjson()
		if fi["userpath"].has(path):
			fi["userpath"].erase(path)
			var save_file = FileAccess.open(Global.SAVEPATH, FileAccess.WRITE)
			save_file.store_string(JSON.stringify(fi))
			save_file.close()
			update_list()
		show_warning("Error accessing path.")

func end():
	add_imgunit()

var current_list : PackedStringArray = []
var end_node : Node = null
var endload := false
func add_imgunit(loadN : int = 10):
	endload = true
	if end_node and end_node.vis.is_connected("screen_entered", end):
		end_node.vis.disconnect("screen_entered", end)
	var unitbox = UNIT_MOD[showmod]
	var next_picn : int = loadN
	if !current_list.size() - image_count > loadN:
		next_picn = current_list.size() - image_count
	for i in range(next_picn):
		var temp = load(unitbox)
		var newunit = temp.instantiate()
		imagebox.add_child(newunit)
		newunit.connect("check", read_info)
		if i == next_picn - 1:
			end_node = newunit
			newunit.vis.connect("screen_entered", end)
		newunit.path = current_list[image_count + i]
	image_count = imagebox.get_child_count()
	endload = false

func background_load():
	if endload:
		return
	if image_count == current_list.size():
		$BackLoad.stop()
		return
	add_imgunit(1)

func read_info(image : String, idx : int):
	$FileShow/InfoBox.path = image
	$FileShow/InfoBox.image_index = idx

func _on_show_mod_item_selected(_index):
	open_path(path_text)
