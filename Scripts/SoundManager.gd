extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play_sfx(category, id=0):
	var idx = 0
	var list_stream = get_sfx(category)
	
	if not list_stream:
		return
	if not id:
		idx = floor(rand_range(0,len(list_stream)))
	else:
		idx = id - 1
	var audio = list_stream[idx]
	audio.playing = true



func get_all_categories():
	var list_name = []
	var nodes = get_node("SFX").get_children()
	for node in nodes:
		list_name.append(node.name)
	return list_name
	

func stop_all_sfx():
	var categories = get_all_categories()
	
	for category in categories:
		var sfxs = get_sfx(category)
		for sfx in sfxs:
			sfx.playing = false
	
func get_sfx(category):
	return get_node("SFX/"+str(category)).get_children()
	
