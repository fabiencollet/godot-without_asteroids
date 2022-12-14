extends RigidBody2D


# Declare member variables here. Examples:
export var rotate_speed: = 18.0
export var boost_speed: = 400

export var max_velocity: = 400
export var shoot_cooldown: = 20.0

# var velocity: = 0.0

onready var screen_size = get_viewport_rect().size
export (Material) var mat_invulnerable

var controller_id :int = 1

var player_name := ""

var is_dead := false

var shield := false

var invulnerability := false

var dead_position: = Vector2.ZERO

var explosion_position: = Vector2.ZERO

var action_boost := ""
var action_turn_left := ""
var action_turn_right := ""
var action_shoot := ""

var shooting := false

var score: = 0

var on_pause = true
var is_boosting = false 

var bullet_size := 1.0
var bullet_hold_speed := 3.0

var shoot_count := 0
var max_shoot_count := 4

# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.game_mode == "Boost Off":
		shield_on()
	var mat = get_node("player_spr").get_material().duplicate()
	get_node("player_spr").set_material(mat)
	set_sprite(4)
	scale = Vector2.ZERO
	$AnimationPlayer.play("Spawn")
	pass # Replace with function body.


func set_sprite(number):
	var texture_path = "res://Assets/Player/player_16_"+str(number)+".png"
	var texture : Texture = load(texture_path)
	
	$player_spr.texture = texture

func set_player_name(new_name):
	name = new_name
	set_action()
	

func set_dead_position(pos):
	dead_position = pos
	
	
func set_explosion_position(pos):
	explosion_position = pos


func set_action():
	
	if Globals.game_mode == "Classic":
		action_boost = "Player_"+str(controller_id)+"_boost"
	action_turn_left = "Player_"+str(controller_id)+"_turn_left"
	action_turn_right = "Player_"+str(controller_id)+"_turn_right"
	action_shoot = "Player_"+str(controller_id)+"_shoot"


func propulsion_off():
	$Propulsion.stop_propulsion()


func dead(_body, velocity):
	
	if shield:
		linear_velocity += (velocity * 1000)
		shield_off()
		return
	
	visible = false
	$Propulsion.stop_propulsion()
	set_explosion_position(global_position)
	
	sleeping = true
	is_dead = true
	linear_velocity = Vector2(0, 0)
	angular_velocity = 0
	global_position.x = dead_position.x
	global_position.y = dead_position.y


func shield_on():
	shield = true
	$CollisionShapeShield/AS_shield_spr.frame = 0
	$CollisionShapeShield/AS_shield_spr.stop()
	$CollisionShape2D.disabled = true
	$CollisionShape2D.visible = false
	$CollisionShapeShield.disabled = false
	$CollisionShapeShield.visible = true

func shield_off():
	set_invulnerability()
	# $shield_off.play()
	shield = false
	$CollisionShape2D.disabled = false
	$CollisionShape2D.visible = true
	$CollisionShapeShield.disabled = true
	$CollisionShapeShield.visible = false
	$CollisionShapeShield/AS_shield_spr.play()

func set_controller_id(id: int=1):
	controller_id = id

func _process(_delta):
	
	if shield:
		$CollisionShapeShield/shield_spr.global_rotation = 0
	
	if is_dead:
		return
	
	if on_pause:
		$AnimatedSprite.visible = false
		return
	
	if position.x < 0:
		global_position.x = screen_size.x
	
	elif position.x > screen_size.x:
		global_position.x = 0
	
	if position.y < 0:
		global_position.y = screen_size.y
		
	elif position.y > screen_size.y:
		global_position.y = 0


func _input(event):
	
	if is_dead or on_pause:
		return
	
	if event.is_action_released(action_shoot):
		if shoot_count < max_shoot_count:
			shooting = true
			shoot_count += 1
			#$AS_shoot_basic.playing = true
		else:
			shooting = false
			
	else:
		shooting = false


func reset_fill():
	$AS_hold_shoot.frame = 0


func _physics_process(delta):
	
	if is_dead or on_pause:
		return
	
	var left = Input.get_action_strength(action_turn_left)
	var right = Input.get_action_strength(action_turn_right)
	var boost = Input.get_action_strength(action_boost)
	var shoot = Input.get_action_strength(action_shoot)
	
	if shoot and shoot_count == 0:
		if bullet_size < 4:
			bullet_size += bullet_hold_speed * delta
		elif bullet_size > 4:
			bullet_size = 4
		$AS_hold_shoot.frame = round((bullet_size-1)*3)
	else:
		reset_fill()
	
	if shoot_count == 0:
		$TimerCoolDown.stop()
	
	if shoot_count > 0:
		if $TimerCoolDown.is_stopped():
			$TimerCoolDown.start()
			$TimerCoolDown.autostart = true
		$AS_hold_shoot.frame = shoot_count * 3
	
	if boost:
		is_boosting = true
		$Propulsion.play_propulsion()
		$AnimatedSprite.visible = true
	else:
		if is_boosting:
			is_boosting = false
			$Propulsion.stop_propulsion()
		$AnimatedSprite.visible = false
	
	var turn = right - left
	
	angular_velocity += turn * rotate_speed * delta
	var direction = Vector2(cos(rotation+(PI/2)), cos(rotation))
	
	var velocity = boost * boost_speed * delta
	
	var impulse = direction * velocity
	
	if(linear_velocity.x > max_velocity * -1 and linear_velocity.x < max_velocity):
		linear_velocity.x += impulse.x
	elif(linear_velocity.x >= max_velocity):
		linear_velocity.x = max_velocity
	elif(linear_velocity.x <= max_velocity * -1):
		linear_velocity.x = max_velocity * -1
		
	if(linear_velocity.y > max_velocity * -1 and linear_velocity.y < max_velocity):
		linear_velocity.y += impulse.y
	elif(linear_velocity.y >= max_velocity):
		linear_velocity.y = max_velocity
	elif(linear_velocity.y <= max_velocity * -1):
		linear_velocity.y = max_velocity * -1


func set_collide():
	if on_pause:
		$CollisionShape2D.disabled = true
	else:
		$CollisionShape2D.disabled = false


func _on_Player_body_entered(body):
	if on_pause:
		return
	if body.get_collision_layer_bit(1):
		for child in body.get_children():
			if child is Button:
				child.focus_mode = 2
				child.grab_focus()
				child.release_focus()
				child.focus_mode = 0
	dead(body, body.linear_velocity/400)


func _on_AS_shoot_basic_animation_finished():
	$AS_shoot_basic.frame = 0
	$AS_shoot_basic.playing = false


func _on_TimerCoolDown_timeout():
	if shoot_count > 0:
		shoot_count -= 1


func _on_AS_shield_spr_animation_finished():
	$CollisionShapeShield.disabled = true
	$CollisionShapeShield.visible = false
	$CollisionShape2D.disabled = false
	$CollisionShape2D.visible = true


func set_invulnerability():
	$TimerInvulnerability.start()
	invulnerability = true
	$player_spr.material.set_shader_param("invulnerable", true)
	
	
func unset_invulnerability():
	invulnerability = false
	$player_spr.material.set_shader_param("invulnerable", false)


func _on_TimerInvulnerability_timeout():
	unset_invulnerability()
	


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Spawn":
		$AS_spawn.visible = true
		$AS_spawn.play()


func _on_AS_spawn_animation_finished():
	$AS_spawn.visible = false
