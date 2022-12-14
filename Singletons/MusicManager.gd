extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cut_high := 1500
var cut_low := 1300


func set_cutoff(high, low):
	var nb_fx = AudioServer.get_bus_effect_count(2)
	for i in range(nb_fx):
		var fx = AudioServer.get_bus_effect(2, i)
		if i == 0:
			fx.cutoff_hz = high
		if i == 1:
			fx.cutoff_hz = low


func _ready():
	set_cutoff(10,20000)


func music_on_pause():
	set_cutoff(cut_high, cut_low)

func music_on_play():
	set_cutoff(10,20000)


func _on_AudioIntro_finished():
	$AudioLoop.play()


func _on_AudioLoop_finished():
	$AudioLoop.play()


func _on_Timer_timeout():
	$AudioIntro.play()
