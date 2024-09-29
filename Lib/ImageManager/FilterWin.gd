extends Window

func _ready():
	close_requested.connect(winhide)

func winhide():
	visible = false
	$"../.."._on_enter_pressed()

func _on_go_fliter_pressed():
	visible = true
	$Filter.file_path = $"../../../../PathBox/Path".text
