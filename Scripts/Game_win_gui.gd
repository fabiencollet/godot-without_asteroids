extends CenterContainer


func _ready():
	$Transition.set_visibility(false)
	if Globals.winner:
		$Label.text = Globals.winner + " Win !!"


func _on_TimerGameWin_timeout():
	$TimerTransition.start()
	$Transition.set_visibility(true)
	$Transition.play_transition_out()


func _on_TimerTransition_timeout():
	Globals.reset_winner()
	get_tree().change_scene("res://Scenes/main_menu.tscn")
