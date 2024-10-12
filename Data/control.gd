extends Control

#var type_name = ["general", "artist", "character", "copyright", "meta"]
#var general : PackedStringArray = []
#var artist : PackedStringArray = []
#var character : PackedStringArray = []
#var copyright : PackedStringArray = []
#var meta : PackedStringArray = []
#var type = [general, artist, character, copyright, meta]

var path : String:
	get:
		path = $LineEdit.text.simplify_path()
		return path

func _on_button_pressed() -> void:
	#if characters:
		#print("Character name: ", characters.name)
		#print("Wiki URL: ", characters.wikiURL)
		## 如果有别名，也可以这样获取
		#if config.has_section_key("content:2k-tan", "alias"):
			#var aliases = config.get_value("content:2k-tan", "alias")
			#print("Aliases: ", aliases)
	#else:
		#print("Character not found")
	#var inf = FileAccess.open("res://Data/tag/output.csv", FileAccess.READ)
	var dir = DirAccess.open(path).get_files()
	for file in dir:
		var filepath : String = path + "/" + file
		var inf = FileAccess.open(filepath, FileAccess.READ)
		var target = FileAccess.open("res://Data/PromptBuilder/temp/" + file.get_basename() + ".csv", FileAccess.WRITE)
		#var temp
		while true:
		#for i in range(15):
			#elif temp.size() > 1:
				#type[int(temp[1])].append(temp[0])
			var ch : String = inf.get_csv_line()[0]
			if ch.is_empty():
				break
			if ch.begins_with("  ") and !ch.begins_with("    ") and !ch.begins_with("  - "):
				var temp : PackedStringArray = [ch.erase(len(ch)-1).dedent()]
				target.store_csv_line(temp)
				#print(ch.erase(len(ch)-1).dedent())
			elif ch.begins_with("      - "):
				var temp : PackedStringArray = [ch.erase(6).dedent()]
				target.store_csv_line(temp)
				#print(ch.erase(6).dedent())
		inf.close()
	print("ok")

func _on_button_2_pressed() -> void:
	print(path)
	#var dir = DirAccess.open("res://Data/PromptBuilder/human").get_files()
	#for i in range(type.size()):
		#var file = FileAccess.open("res://Data/" + type_name[i] + ".csv", FileAccess.WRITE)
		#for t in type[i]:
			#var temp : PackedStringArray = [t]
			#file.store_csv_line(temp)
		#file.close()
	print("okok")

func _on_button_3_pressed() -> void:
	var dir = DirAccess.open(path).get_files()
	for file in dir:
		var filepath : String = path + "/" + file
	pass # Replace with function body.
