extends HBoxContainer

var rule_mode : int = 0
var key : String = ""

func _on_rule_item_selected(index):
	rule_mode = index

func _on_keyword_text_changed(new_text):
	key = new_text

func _on_delete_button_up():
	queue_free()
