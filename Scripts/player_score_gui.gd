extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player_name := ""

var max_victory := 5

var last_score := 0
var current_score := 0

var list_star := Array()


func set_max_victory(victory):
	max_victory = victory
	
	list_star.append($HBoxContainer/CenterContainer/AnimatedSprite)
	
	$HBoxContainer.rect_min_size = Vector2(40*victory, 32)
	var pivot_x = ((40*victory)/2)+200
	rect_pivot_offset = Vector2(pivot_x, 16)
	
	for _i in range(victory-1):
		var new_container = $HBoxContainer/CenterContainer.duplicate()
		var new_star = new_container.get_child(0)
		$HBoxContainer.add_child(new_container)
		list_star.append(new_star)
	
	for star in list_star:
		star.visible = false
	
# Called when the node enters the scene tree for the first time.
func _ready():
	rect_scale = Vector2(0, 0)
	pass

func set_player_name(name):
	$Label.text = name
	player_name = name
	
	var player_idx = name.to_lower().split("_")[-1]
	
	var base_path = "res://Assets/Player/player_16_"
	
	var texture_path = base_path + player_idx + ".png"
	var texture : Texture = load(texture_path)
	
	$CenterPlayer/PlayerSprite_GUI.texture = texture
	
	
func set_player_score(score):
	current_score = score
	$LabelCount.text = str(current_score) + "/" + str(max_victory)
	
	$TimerStar.start()



func _on_TimerStar_timeout():
	if current_score - 1 >= 0:
		for i in range(current_score-1):
			list_star[i].frame = 9
			list_star[i].playing = true
			list_star[i].visible = true
		
		list_star[current_score-1].playing = true
		list_star[current_score-1].visible = true
