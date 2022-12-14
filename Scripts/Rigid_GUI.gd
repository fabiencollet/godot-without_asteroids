extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (Array) var list_child_areas

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	
	
	if position.x < 0:
		global_position.x = Globals.screen_size.x
	
	elif position.x > Globals.screen_size.x:
		global_position.x = 1
	
	if position.y < 0:
		global_position.y = Globals.screen_size.y
		
	elif position.y > Globals.screen_size.y:
		global_position.y = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
