extends Window

func _ready():
	close_requested.connect(hide)

func _on_go_fliter_pressed():
	visible = true
