extends MarginContainer

@onready var output = $"Tag Manage/Input/Output"
@onready var tagbox = $"Tag Manage/Taginformation/TagsBox/Box/Tags"

func sort_by_times(a, b):
	if a[1] < b[1]:
		return true
	return false

var processed := false
var txt_path : String
var file_list : PackedStringArray

func _on_run_button_up():
	txt_path = $"Tag Manage/Input/Path".text
	var dir = DirAccess.open(txt_path)
	if dir:
		output.text = "Processing..."
		processed = true
		# 重置
		for child in tagbox.get_children():
			child.queue_free()
		most_times = 0
		
		# 获取所有tag词频
		var templist = dir.get_files()
		var _tags : Dictionary = {}
		var error_count : int = 0
		for file in templist:
			if Global.IMAGE_TYPE.has(file.get_extension()):
				var image_file : String = (txt_path+"/"+file).simplify_path()
				var full_path : String = image_file.get_basename() + ".txt"
				if FileAccess.file_exists(full_path):
					var caption : String = FileAccess.get_file_as_string(full_path)
					if "Error" in caption:
						error_count += 1
						continue
					file_list.append(file)
					var temp : PackedStringArray = caption.split(",", false)
					var newtemp : PackedStringArray = []
					for temptag in temp:
						# 标准化分隔
						var newtemptag = temptag.dedent()
						if _tags.has(newtemptag):
							_tags[newtemptag][0] += 1
							_tags[newtemptag][1].append(file)
						else:
							var filepack : PackedStringArray = [file]
							_tags[newtemptag] = [1, filepack]
						newtemp.append(temptag)
					var new_caption = ",".join(newtemp)
					var save_file = FileAccess.open(full_path, FileAccess.WRITE)
					save_file.store_string(new_caption)
					save_file.close()
		
		# 重置排序，挑出top
		var top : int = int($"Tag Manage/Input/TopN".value)
		var tags : Array = []
		for key in _tags:
			tags.append([key, _tags[key][0], _tags[key][1]]) # tag,times,file
		tags.sort_custom(sort_by_times)
		var top_tags : Dictionary = {}
		for i in range(top):
			var temp = tags.pop_back()
			if most_times == 0:
				most_times = temp[1]
			if temp:
				top_tags[temp[0]] = [temp[1], temp[2]]
				cloud_table[temp[0]] = temp[1]
			else:
				break
		
		# 生成词云
		word_cloud()
		
		# 生成列表，放入box
		var translater : int = $"Tag Manage/Input/Translate".selected
		for key in top_tags:
			var loadtemp = load("res://Lib/TagProcess/tag.tscn")
			var onetag = loadtemp.instantiate()
			tagbox.add_child(onetag)
			onetag.tag.text = key
			onetag.times.text = str(top_tags[key][0])
			onetag.image_file = top_tags[key][1]
			onetag.path = txt_path
			if translater != 2:
				onetag.translate(translater)
		output.text = "Reading complete. " + str(error_count) + " error captions."
	else:
		output.text = "Error accessing path."

func _on_add_button_up():
	if processed:
		output.text = "Processing..."
		var new_tag : String = $"Tag Manage/Newbox/NewTag".text
		var insert_mod : int = $"Tag Manage/Newbox/AddMode".selected
		
		# 修改所有文件
		for file in file_list:
			var image_file : String = (txt_path+"/"+file).simplify_path()
			var full_path : String = image_file.get_basename() + ".txt"
			var caption : String = FileAccess.get_file_as_string(full_path)
			var temp : PackedStringArray = caption.split(",", false)
			var pos : int
			if insert_mod == 0:
				pos = 0
			elif insert_mod == 1:
				@warning_ignore("integer_division")
				pos = temp.size() / 2
			else:
				pos = temp.size()
			temp.insert(pos, new_tag)
			var new_caption = ", ".join(temp)
			var save_file = FileAccess.open(full_path, FileAccess.WRITE)
			save_file.store_string(new_caption)
			save_file.close()
		
		# 生成词云
		cloud_table[new_tag] = file_list.size()
		word_cloud()
		
		# 加入box
		var translator : int = $"Tag Manage/Input/Translate".selected
		var loadtemp = load("res://Lib/tag.tscn")
		var onetag = loadtemp.instantiate()
		tagbox.add_child(onetag)
		onetag.tag.text = new_tag
		onetag.times.text = str(file_list.size())
		onetag.image_file = file_list
		onetag.path = txt_path
		tagbox.move_child(onetag, 0)
		if translator != 2:
			onetag.translate(translator)
		output.text = "Completed."

var cloud_table : Dictionary = {}
var most_times : int = 0
func word_cloud():
	var cloud = $"Tag Manage/Taginformation/Word Cloud/WordCloud"
	cloud.create_cloud(cloud_table, most_times)
