extends Control

var type_name = ["general", "artist", "character", "copyright", "meta"]
var general : PackedStringArray = []
var artist : PackedStringArray = []
var character : PackedStringArray = []
var copyright : PackedStringArray = []
var meta : PackedStringArray = []
var type = [general, artist, character, copyright, meta]

func _on_button_pressed() -> void:
	#var inf = FileAccess.open("res://Data/tag/output.csv", FileAccess.READ)
	#var temp
	#var empty := false
	#while !empty:
		#temp = inf.get_csv_line()
		#if temp.is_empty() or temp[0].is_empty():
			#empty = true
		#elif temp.size() > 1:
			#type[int(temp[1])].append(temp[0])
	#inf.close()
	var inf = FileAccess.open("res://Data/Danbooru2023/general.csv", FileAccess.READ)
	for i in range(10):
		print(inf.get_csv_line())
	print("ok")

func _on_button_2_pressed() -> void:
	for i in range(type.size()):
		var file = FileAccess.open("res://Data/" + type_name[i] + ".csv", FileAccess.WRITE)
		for t in type[i]:
			var temp : PackedStringArray = [t]
			file.store_csv_line(temp)
		file.close()
	print("okok")
