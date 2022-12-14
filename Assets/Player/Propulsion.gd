extends Node


func play_propulsion():
	$Propulsion_loop.stream_paused = false

func stop_propulsion():
	$Propulsion_loop.stream_paused = true


func _on_Propulsion_intro_finished():
	$Propulsion_loop.play()


func _on_Propulsion_loop_finished():
	$Propulsion_loop.play()
