extends Control

func updatepos():
	$Right.position.x = size.x
	$Down.position.y = size.y - 200

func _on_resized():
	updatepos()

func _ready():
	updatepos()

var maxsize : int = 70
var minsize : int = 10
const tagbody = "res://Lib/TagProcess/tagbody.tscn"
func create_cloud(cloud_table : Dictionary, most_times : int):
	for child in $TagBoxs.get_children():
		child.queue_free()
	for key in cloud_table:
		var fontsize : int = clampi(int((cloud_table[key] / float(most_times)) * maxsize), minsize, maxsize)
		var temp = load(tagbody)
		var newcloud = temp.instantiate()
		$TagBoxs.add_child(newcloud)
		newcloud.take_texture(fontsize, key)
