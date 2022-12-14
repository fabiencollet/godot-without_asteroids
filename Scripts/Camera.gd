extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var is_skake: = false 

export (Vector2) var frequency
export (Vector2) var amplitude

func _process(_delta):
	
	if not is_skake:
		return
	
	var time = $Timer.wait_time - $Timer.time_left
	
	var multiply = inverse_lerp(0, $Timer.wait_time, $Timer.time_left)
	
	offset.x = (sin(time * frequency.x) * amplitude.x) * multiply
	offset.y = (sin(time * frequency.y) * amplitude.y) * multiply
	

func screen_shake():
	$Timer.start()
	is_skake = true


func _on_Timer_timeout():
	$Timer.stop()
	is_skake = false
