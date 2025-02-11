extends MarginContainer

@onready var output = $"Tag Manage/Input2/Output"
@onready var tagbox = $"Tag Manage/Taginformation/TagsBox/Box/Tags"

func sort_by_times(a, b):
	if a[1] < b[1]:
		return true
	return false

var processed := false
var txt_path : String:
	get:
		return $"Tag Manage/Input/Path".text
var file_list : PackedStringArray
var alltag_list : Dictionary = {}

const HEADER = preload("res://Lib/TagManager/header.tscn")
func _on_run_button_up():
	$"Tag Manage/Input/Path".editable = false
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
			if Global.IMAGE_TYPE.has(file.get_extension().to_upper()):
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
						
						# 清理停用词
						if $"Tag Manage/Input2/Stopword".pressed:
							newtemptag = Global.remove_stopword(newtemptag)

						newtemp.append(newtemptag)
					var new_caption = ",".join(newtemp)
					var save_file = FileAccess.open(full_path, FileAccess.WRITE)
					save_file.store_string(new_caption)
					save_file.close()
		
		var head = HEADER.instantiate()
		tagbox.add_child(head)
		if !_tags.is_empty():
			# 重置排序，挑出top
			var top : int = clampi(_tags.size(), 1, int($"Tag Manage/Input/TopN".value))
			var tags : Array = []
			for key in _tags.keys():
				tags.append([key, _tags[key][0], _tags[key][1]]) # tag(string),times(int),file(PackedStringArray)
			tags.sort_custom(sort_by_times)
			for taginfo in tags:
				alltag_list[taginfo[0]] = taginfo[2]
			var top_tags : Dictionary = {}
			for i in range(top):
				var temp = tags.pop_back()
				if most_times == 0:
					most_times = temp[1]
				top_tags[temp[0]] = [temp[1], temp[2]]
				cloud_table[temp[0]] = temp[1]
			
			# 生成词云
			word_cloud()
			
			# 生成列表，放入box
			var translater : int = $"Tag Manage/Input2/Translate".selected
			for key in top_tags.keys():
				var loadtemp = load("res://Lib/TagManager/tag.tscn")
				var onetag = loadtemp.instantiate()
				tagbox.add_child(onetag)
				onetag.tag = key
				onetag.times = str(top_tags[key][0])
				onetag.image_file = top_tags[key][1]
				onetag.path = txt_path
				if translater != 2:
					onetag.translate(translater)
			output.text = "Reading complete. " + str(error_count) + " error captions."
		else:
			output.text = "No captions."
	else:
		output.text = "Error accessing path."
	
	$"Tag Manage/Input/Path".editable = true

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
				pos = int(temp.size() / 2.0)
			else:
				pos = temp.size()
			temp.insert(pos, new_tag)
			var new_caption = ",".join(temp)
			var save_file = FileAccess.open(full_path, FileAccess.WRITE)
			save_file.store_string(new_caption)
			save_file.close()
		
		# 生成词云
		cloud_table[new_tag] = file_list.size()
		word_cloud()
		
		# 加入box
		var translator : int = $"Tag Manage/Input2/Translate".selected
		var loadtemp = load("res://Lib/TagManager/tag.tscn")
		var onetag = loadtemp.instantiate()
		tagbox.add_child(onetag)
		onetag.tag = new_tag
		onetag.times = str(file_list.size())
		onetag.image_file = file_list
		onetag.path = txt_path
		tagbox.move_child(onetag, 0)
		if translator != 2:
			onetag.translate(translator)
		output.text = "Completed."

var cloud_table : Dictionary = {}
var most_times : int = 0
@onready var cloud = $"Tag Manage/Taginformation/Word Cloud/WordCloud"
func word_cloud():
	if $"Tag Manage/Taginformation/Word Cloud/Show".button_pressed:
		cloud.create_cloud(cloud_table, most_times)

func _on_show_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$"Tag Manage/Taginformation/Word Cloud/Show".text = "Word Cloud Show"
		word_cloud()
		cloud.visible = true
	else:
		$"Tag Manage/Taginformation/Word Cloud/Show".text = "Show"
		cloud.visible = false
		cloud.free_child()

const Danbooru2023 = ["res://Data/Danbooru2023/artist.csv",
						"res://Data/Danbooru2023/character.csv",
						"res://Data/Danbooru2023/copyright.csv",
						"res://Data/Danbooru2023/general.csv",
						"res://Data/Danbooru2023/meta.csv"]
func _on_sort_tag_pressed() -> void:
	if file_list.is_empty():
		return
	var database : Array = []
	for csv in Danbooru2023:
		var data := []
		var csvdata = FileAccess.open(csv, FileAccess.READ)
		while true:
			var ch : String = csvdata.get_csv_line()[0]
			if ch.is_empty():
				break
			data.append(ch)
		database.append(data)
		csvdata.close()
	for file in file_list:
		var full_path : String = file.get_basename() + ".txt"
		var caption : String = FileAccess.get_file_as_string(full_path)
		var temp : PackedStringArray = caption.split(",", false)
		var findtag : Array[PackedStringArray] = [[],[],[],[],[]]
		for tag in temp:
			for i in database.size():
				if database[i].has(tag):
					findtag[i].append(tag)
					temp.remove_at(temp.find(tag))
					break
		var packedtemp : PackedStringArray = []
		for arr in findtag:
			packedtemp.append_array(arr)
		packedtemp.append_array(temp)
		var new_caption = ",".join(packedtemp)
		var save_file = FileAccess.open(full_path, FileAccess.WRITE)
		save_file.store_string(new_caption)
		save_file.close()
	$"Tag Manage/Input2/Output".text = "Tag sort completed."
