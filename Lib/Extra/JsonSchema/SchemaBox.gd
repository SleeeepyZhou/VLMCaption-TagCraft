extends HBoxContainer

var formatname : String = ""

func send() -> Dictionary:
	var formatdir = Global.readjson()["format"]
	if formatname.is_empty() or !formatdir.has(formatname):
		return {}
	var format : Dictionary = formatdir[formatname]
	format.erase("Note")
	return format

func updata_list():
	$SchemaList.clear()
	var formatdir = Global.readjson()["format"]
	for format in formatdir:
		$SchemaList.add_item(format)

func _ready():
	if !FileAccess.file_exists(Global.SAVEPATH):
		return
	updata_list()

func _on_schema_list_item_selected(index):
	formatname = $SchemaList.get_item_text(index)

func _on_edit_pressed():
	formatname = $SchemaList.text
	%Editbox.visible = true
	%Editbox.readformat(formatname)

func _on_new_pressed():
	%Editbox.visible = true
	%Editbox.newformat()

func _on_delete_button_up():
	var taget = $SchemaList.text
	if taget.is_empty():
		return
	var dir = Global.readjson()
	dir["format"].erase(taget)
	var save_file = FileAccess.open(Global.SAVEPATH, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(dir))
	save_file.close()
	updata_list()

func buttun_visible(lock : bool):
	$SchemaList.visible = lock
	$Edit.visible = lock
	$New.visible = lock
	$Delete.visible = lock
func _on_schema_toggled(toggled_on):
	buttun_visible(toggled_on)
	%ApiUtils.formatrespon = toggled_on
