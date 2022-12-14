extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (PackedScene) var Explosion

export var speed: = 1000.0

onready var screen_size = get_viewport_rect().size

onready var collider = get_node("CollisionShape2D")

onready var invulnerable = true

var bullet_owner

var bullet_size := 1.0

var current_position: Vector2 = Vector2.ZERO
var previous_position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var distance: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	current_position = global_position
	previous_position = global_position
	$AnimationPlayer.play("simple")
	pass # Replace with function body.

func set_bullet_size(size):
	if size > bullet_size:
		scale = Vector2(size , 1 + (size/2))

func set_bullet_owner(player):
	bullet_owner = player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if position.x < 0:
		global_position.x = screen_size.x
	
	elif position.x > screen_size.x:
		global_position.x = 0
	
	if position.y < 0:
		global_position.y = screen_size.y
		
	elif position.y > screen_size.y:
		global_position.y = 0
	
	move_local_y(speed * delta)
	

func _physics_process(_delta):
	current_position = global_position
	var x1: float = current_position.x
	var y1: float = current_position.y
	var x2: float = previous_position.x
	var y2: float = previous_position.y
	distance = sqrt(pow(x2-x1, 2)+pow(y2-y1, 2))
	velocity = current_position - previous_position
	if distance:
		$RayCast2D.cast_to.y = distance
	previous_position = global_position
	
	if $RayCast2D.is_colliding():
		body_collide($RayCast2D.get_collider())


func _on_Timer_timeout():
	#print("Delete")
	queue_free()


func _on_Bullet_body_entered(body):
	
	body_collide(body)

func body_collide(body):
	if not body.get_collision_layer_bit(0):
		queue_free()
		return
	
	if invulnerable and body == bullet_owner:
		return
	
	if body.invulnerability:
		queue_free()
		return
	
	body.dead(body, (velocity/250)*scale) 
	queue_free()
	

func _on_Timer_invinsible_timeout():
	invulnerable = false
