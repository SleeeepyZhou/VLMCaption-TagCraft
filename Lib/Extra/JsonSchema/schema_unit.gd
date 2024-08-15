extends HBoxContainer

var key : String = "":
	get:
		key = $Keyword.text
		return key
var is_object : bool = false
var note : String = "":
	get:
		note = $Note.text
		return note

func update_text(keyword : String, combin : bool, notaword : String):
	key = keyword
	is_object = combin
	note = notaword
	$Keyword.text = keyword
	$Combination.button_pressed = combin
	$Note.text = notaword

func send_properties(notedir : Dictionary = {}):
	var properties : Dictionary = {}
	notedir[key] = note
	if is_object:
		var object : Dictionary = {}
		var box : PackedStringArray = []
		for child in $Unitbox.get_children():
			var unit_pp = child.send_properties(notedir)
			if unit_pp[0].is_empty():
				continue
			box.append(unit_pp[0])
			object[unit_pp[0]] = unit_pp[1]
			notedir = unit_pp[2]
		if object.is_empty():
			properties["type"] = "string"
		else:
			properties["type"] = "object"
			properties["properties"] = object
			properties["required"] = box
			properties["additionalProperties"] = false
	else:
		properties["type"] = "string"
	return [key, properties, notedir]

func _on_combination_toggled(toggled_on):
	if toggled_on:
		$Add.visible = true
		is_object = true
	else:
		$Add.visible = false
		is_object = false
		for child in $Unitbox.get_children():
			child.queue_free()

func _on_add_pressed():
	var temp = load("res://Lib/Extra/JsonSchema/schema_unit.tscn")
	var newunit = temp.instantiate()
	$Unitbox.add_child(newunit)

func _on_delete_button_up():
	queue_free()
