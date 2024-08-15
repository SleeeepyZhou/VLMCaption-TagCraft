extends HBoxContainer

var rule_mode : int = 0:
	get:
		rule_mode = $Rule.selected
		return rule_mode
var key : String = "":
	get:
		key = $Keyword.text
		return key

func _on_delete_button_up():
	queue_free()
