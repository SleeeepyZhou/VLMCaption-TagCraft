extends MarginContainer

const unit_path = "res://Lib/Extra/JsonSchema/schema_unit.tscn"

func newformat():
	$SchemaEdit/Box/Namebox/Name.text = ""
	$SchemaEdit/Box/Namebox/Note.text = ""
	for child in $SchemaEdit/Box/Box/Unitbox.get_children():
		child.queue_free()
	_on_add_pressed()

'''
example_data = {
		"model": "gpt-4o-2024-08-06",
		"messages": [{"role": "user",
					"content": [{"type": "text",
								"text": "Example prompt"}]
					}],
		"max_tokens": 300,
		"temperature": 0.2,
		"response_format": {"type": "json_schema",
							"json_schema": {"name": "image_analysis_response",
											"strict": true,
											"schema": {"type": "object",
														"properties": {"category": { "type": "string" },
																		"subject": { "type": "string" },
																		"appearance": {"type": "object",
																						"properties": {"costume": { "type": "string" },
																										"prop": { "type": "string" },
																										"expression": { "type": "string" }},
																						"required": ["costume", "prop", "expression"],
																						"additionalProperties": false},
																		"environment": {"type": "object",
																						"properties": {"location": { "type": "string" },
																										"time_of_day": { "type": "string" },
																										"mood": { "type": "string" }},
																						"required": ["location", "time_of_day", "mood"],
																						"additionalProperties": false},
																		"photography_details": {"type": "object",
																								"properties": {"shot_type": { "type": "string" },
																												"lighting": { "type": "string" },
																												"background": { "type": "string" }},
																								"required": ["shot_type", "lighting", "background"],
																								"additionalProperties": false}
																		},
														"required": ["category", "subject", "appearance", "environment", "photography_details"],
														"additionalProperties": false}
											}
							}
				}
example_answer = {
		"category": "",
		"subject": "",
		"appearance": {
						"costume": "",
						"prop": "", 
						"expression": ""
						},
		"environment": {
						"location": "",
						"time_of_day": "",
						"mood": ""
						},
		"photography_details": {
						"shot_type": "",
						"lighting": "",
						"background": ""}
						}
example_schema = {
		"type": "object",
		"properties": {"category": { "type": "string" },
						"subject": { "type": "string" },
						"appearance": {"type": "object",
										"properties": {"costume": { "type": "string" },
														"prop": { "type": "string" },
														"expression": { "type": "string" }},
										"required": ["costume", "prop", "expression"],
										"additionalProperties": false},
						"environment": {"type": "object",
										"properties": {"location": { "type": "string" },
														"time_of_day": { "type": "string" },
														"mood": { "type": "string" }},
										"required": ["location", "time_of_day", "mood"],
										"additionalProperties": false},
						"photography_details": {"type": "object",
												"properties": {"shot_type": { "type": "string" },
																"lighting": { "type": "string" },
																"background": { "type": "string" }},
												"required": ["shot_type", "lighting", "background"],
												"additionalProperties": false}
						},
		"required": ["category", "subject", "appearance", "environment", "photography_details"],
		"additionalProperties": false
				}
'''

func analysis(box : Control, properties : Dictionary, notedir : Dictionary):
	for key in properties:
		var temp = load(unit_path)
		var newunit = temp.instantiate()
		box.add_child(newunit)
		var combin : bool = properties[key]["type"] in "object"
		newunit.update_text(key, combin, notedir[key])
		if combin:
			var newbox = newunit.get_node("Unitbox")
			analysis(newbox, properties[key]["properties"], notedir)
	
func readformat(format_name : String):
	if format_name.is_empty():
		newformat()
		return
	var formatdir = Global.readjson()["format"][format_name]
	var schema = formatdir["json_schema"]["schema"]
	var notedir = formatdir["Note"]
	$SchemaEdit/Box/Namebox/Name.text = format_name
	$SchemaEdit/Box/Namebox/Note.text = notedir[format_name.to_upper()]
	analysis($SchemaEdit/Box/Box/Unitbox, schema["properties"], notedir)

func _on_esc_pressed():
	visible = false

func _on_add_pressed():
	var temp = load(unit_path)
	var newunit = temp.instantiate()
	$SchemaEdit/Box/Box/Unitbox.add_child(newunit)

func _on_save_pressed():
	var format : Dictionary = {
								"type": "json_schema",
								"json_schema": {"name": "",
												"strict": true}
								}
	var schema : Dictionary = {"type": "object"}
	
	# 存方法名
	var schema_name = $SchemaEdit/Box/Namebox/Name.text
	if schema_name.is_empty():
		$SchemaEdit/Warning.text = "Where's my name?"
		$SchemaEdit/Warning.visible = true
		await get_tree().create_timer(3).timeout
		$SchemaEdit/Warning.visible = false
		return
	format["json_schema"]["name"] = schema_name
	
	# 初始盒子
	var box : PackedStringArray = []
	var object : Dictionary = {}
	var notedir : Dictionary = {}
	notedir[schema_name.to_upper()] = $SchemaEdit/Box/Namebox/Note.text
	for child in $SchemaEdit/Box/Box/Unitbox.get_children():
		var unit_pp = child.send_properties(notedir)
		if unit_pp[0].is_empty():
			continue
		box.append(unit_pp[0])
		object[unit_pp[0]] = unit_pp[1]
		notedir = unit_pp[2]
	if object.is_empty():
		$SchemaEdit/Warning.text = "Please type something, plz"
		$SchemaEdit/Warning.visible = true
		await get_tree().create_timer(3).timeout
		$SchemaEdit/Warning.visible = false
		return
	
	schema["properties"] = object
	schema["required"] = box
	schema["additionalProperties"] = false
	format["Note"] = notedir
	format["json_schema"]["schema"] = schema
	
	var dir = Global.readjson()
	dir["format"][schema_name] = format
	var save_data = FileAccess.open(Global.SAVEPATH, FileAccess.WRITE)
	save_data.store_string(JSON.stringify(dir))
	save_data.close()
	
	%SchemaBox.updata_list()
