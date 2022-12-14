extends Node


var total_delta := 0.0
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$AnimationPlayer.current_animation = "splash_screen_anim"
	$Transition.set_visibility(false)

	

func _on_Timer_timeout():
	$Transition.set_visibility(true)
	$TimerTransition.start()
	$Transition.play_transition_out()
	

func _process(delta):
	total_delta += delta


func _on_AnimationPlayer_animation_finished(_anim_name):
	$Timer.start()


func _on_TimerTransition_timeout():
	var _error = get_tree().change_scene("res://Scenes/main_menu.tscn")


func _on_TimerDelta_timeout():
	#print(total_delta)
	pass
