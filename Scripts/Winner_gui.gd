extends CenterContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (PackedScene) var PlayerScore

onready var label = get_node("VBoxContainer/LabelWinner")

onready var widget_score_list = [] 

# Called when the node enters the scene tree for the first time.
func _ready():
	# $VBoxContainer/HSeparator.visible = false
	# modulate = Color(1, 1, 1, 0)
	pass # Replace with function body.

func play_animation_in():
	$AnimationPlayer.play("Anim_in")


func add_score_widget(name):
	var widget = PlayerScore.instance()
	widget.set_player_name(name)
	var parent: = get_node("VBoxContainer")
	parent.add_child(widget)
	widget_score_list.append(widget)

func set_max_victory(victory):
	if not widget_score_list:
		return
		
	for widget in widget_score_list:
		widget.set_max_victory(victory)

func update_player_score(player_name, new_score):
	if not widget_score_list:
		return
	
	for widget in widget_score_list:
		if widget.player_name == player_name:
			widget.set_player_score(new_score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func show_players_score():
	if not widget_score_list:
		return

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Anim_in":
		$Timer.start()
		show_players_score()


func _on_Timer_timeout():
	$AnimationPlayer.play("Anim_out")
