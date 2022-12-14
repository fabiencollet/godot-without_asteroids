extends Node2D



var players_list: = []
var bullets_list: = []

export (PackedScene) var Player
export (PackedScene) var Bullet
export (PackedScene) var Explosion
export (PackedScene) var PauseMenu

export var player_offset: = 100

var list_gamepad := Array()

var win_gui_visible: = false

var game_in_pause = true
var in_game = true

var pause_menu = null

onready var init_translations: =[
		[player_offset, player_offset],
		[Globals.screen_size.x - player_offset, Globals.screen_size.y - player_offset],
		[Globals.screen_size.x - player_offset, player_offset],
		[player_offset, Globals.screen_size.y - player_offset],
		]
		
onready var init_rotations: =[-45, 135, 45, -135]

onready var init_dead_translations: =[
		[-player_offset*10, -player_offset*10],
		[Globals.screen_size.x + player_offset*10, Globals.screen_size.y*10 + player_offset*10],
		[Globals.screen_size.x + player_offset*10, -player_offset*10],
		[-player_offset*10, Globals.screen_size.y + player_offset*10],
		]

var players_explode = []


func refresh_players():
	
	remove_all_players()
	players_list = []
	players_explode = []
	
	for _i in range(Globals.max_players):
		players_explode.append(false)
	
	var nb_joypads = len(Input.get_connected_joypads())
	
	var joypads_id := 0
	var nb_players_keyboard = Globals.nb_players - nb_joypads
	
	for i in range(Globals.nb_players):
		
		var player = Player.instance()
		$players_grp.add_child(player)
		players_list.append(player)
		player.position.x = init_translations[i][0]
		player.position.y = init_translations[i][1]
		player.rotation_degrees = init_rotations[i]
		
		var dead_pos = Vector2(
			init_dead_translations[i][0],
			init_dead_translations[i][1]
		)
		
		player.set_dead_position(dead_pos)
		
		
		if nb_players_keyboard <= 0 or i > 1:
			if joypads_id < nb_joypads:
				player.set_controller_id(3 + joypads_id)
			if joypads_id >= nb_joypads:
				player.set_controller_id(1)
			joypads_id += 1
		else :
			player.set_controller_id(i+1)
			nb_players_keyboard -= 1
			
		player.set_player_name("Player_" + str(i+1))
		player.set_sprite(i+1)


func _ready():
	
	for gamepad in Input.get_connected_joypads():
		list_gamepad.append(gamepad)
	
	refresh_players()
	
	if in_game:
		pause()
		$TimerRestorePause.start()
	else:
		play()


func add_player():
	var i := len(players_list)
	var player = Player.instance()
	$players_grp.add_child(player)
	players_list.append(player)
	player.position.x = init_translations[i][0]
	player.position.y = init_translations[i][1]
	player.rotation_degrees = init_rotations[i]
	
	var dead_pos = Vector2(
		init_dead_translations[i][0],
		init_dead_translations[i][1]
	)
	
	player.set_dead_position(dead_pos)
	
	player.set_controller_id(i)
	player.set_player_name("Player_" + str(i+1))
	player.set_sprite(i+1)


func remove_all_players():
	for _i in range(len(players_list)):
		remove_player()


func remove_player():
	var player = players_list[-1]
	$players_grp.remove_child(player)
	players_list.remove(players_list.find(player))
	

func explode(pos):
	var explosion = Explosion.instance()
	explosion.global_position = pos
	add_child(explosion)
	$Camera2D.screen_shake()
	$SoundManager.play_sfx("Explosion")
	for gamepad in list_gamepad:
		Input.start_joy_vibration(gamepad, 1, 1, 1)


func check_for_explosion(my_list):
	if game_in_pause:
		return
		
	for node in my_list:
		if not node.visible:
			var i = my_list.find(node) 
			if not players_explode[i]:
				explode(node.explosion_position)
				players_explode[i] = true
				
	check_for_winner()


func all_players_dead():
	var all_dead = true
	
	for player in players_list:
		if player.visible:
			all_dead = false
			
	return all_dead


func check_for_winner():
	var nb_dead = 0
	
	if win_gui_visible == false:
		
		for player in players_list:
			if not player.visible:
				nb_dead += 1
				
	if nb_dead >= Globals.nb_players-1:
		win_gui_visible = true
		return true
	else:
		return false

func _process(_delta):
	
#	if in_game and game_in_pause:
	if pause_menu != null:
		if pause_menu.resume:
			$SoundManager.play_sfx("Countdown")
			reset_players_when_pause()
			$TimerRestorePause.start()
			$AnimatedTimer.frame = 0
			$AnimatedTimer.visible = true
			$AnimatedTimer.playing = true
			pause_menu.queue_free()
			pause_menu = null
	
	check_shoot()
	check_for_explosion(players_list)


func reset_players_when_pause():
	
	delete_bullets()
	
	win_gui_visible = false
	
	for player in players_list:
		
		player.bullet_size = 1.0
		player.reset_fill()
		
		if player.visible:
			var i = players_list.find(player)
			
			player.set_explosion_position(Vector2.ZERO)
			
			player.linear_velocity = Vector2(0, 0)
			player.angular_velocity = 0
			player.is_dead = false
			player.sleeping = false
			player.global_position.x = init_translations[i][0]
			player.global_position.y = init_translations[i][1]
			player.rotation_degrees = init_rotations[i]


func need_shield(player):
	# if Globals.nb_rounds_to_win < 3:
		# return false
	var need_a_shield := false
# warning-ignore:integer_division
	var difference := Globals.nb_rounds_to_win / 2.0
	for p in players_list:
		if player.name == p.name:
			continue
		var player_difference = p.score - player.score
		if player_difference >= difference:
			need_a_shield = true
			return need_a_shield
		
	return need_a_shield


func reset_players(with_timer=true):
	
	
	players_explode = [false, false, false, false]
	
	win_gui_visible = false
	
	delete_bullets()
	
	for player in players_list:
		player.unset_invulnerability()
		player.bullet_size = 1.0
		player.reset_fill()
		player.visible = true
		var i = players_list.find(player)
		
		player.set_explosion_position(Vector2.ZERO)
		
		player.global_position.x = init_translations[i][0]
		player.global_position.y = init_translations[i][1]
		player.rotation_degrees = init_rotations[i]
		player.linear_velocity = Vector2(0, 0)
		player.angular_velocity = 0
		player.is_dead = false
		player.sleeping = false
		if need_shield(player) or Globals.game_mode == "Boost Off":
			player.shield_on()
		else:
			player.shield_off()
	
	if with_timer:
		pause()
		$TimerRestorePause.start()
		$SoundManager.play_sfx("Countdown")
		$AnimatedTimer.frame = 0
		$AnimatedTimer.visible = true
		$AnimatedTimer.playing = true
	


func delete_bullets():
	for bullet in bullets_list:
		if is_instance_valid(bullet):
			bullet.queue_free()
			
	bullets_list = []


func get_all_scores():
	var all_scores = []
	for player in players_list:
		all_scores.append([player.name, player.score])
	
	return all_scores
	

func check_shoot():
	if game_in_pause:
		return
	for player in players_list:
		if not player.shooting:
			continue
		
		var direction = Vector2(cos(player.rotation+(PI/2)), cos(player.rotation))
		var bullet = Bullet.instance()
		bullet.set_bullet_size(player.bullet_size)
		bullet.global_position = player.position + (direction * 16)
		bullet.rotation = player.rotation
		bullet.set_bullet_owner(player)
		# bullet.apply_impulse(Vector2(0, 0), player.direction * bullet.speed)
		$bullets_grp.add_child(bullet)
		bullets_list.append(bullet)
		
		$SoundManager.play_sfx("Laser", player.bullet_size)
		
		
		var b_size = (player.bullet_size * 1.5) - 1.0
		
		if player.bullet_size > 1.5:
			player.apply_central_impulse(direction*(-30*(b_size*b_size)))
		
		player.shooting = false
		player.bullet_size = 1.0
		player.reset_fill()


func all_propulsion_pause():
	
	for player in players_list:
		player.propulsion_off()


func pause():
	$TimerTransition.stop()
	$TimerRestorePause.stop()
	MusicManager.music_on_pause()
	all_propulsion_pause()
	delete_bullets()
	for player in players_list:
		player.bullet_size = 1.0
		player.reset_fill()
		player.on_pause = true
		player.set_collide()
	game_in_pause = true
	$AnimatedTimer.frame = 0
	$AnimatedTimer.visible = false
	$AnimatedTimer.playing = false
	reset_players_when_pause()

func play():
	for player in players_list:
		player.bullet_size = 1.0
		player.reset_fill()
		player.on_pause = false
		player.set_collide()
	game_in_pause = false
	
	$AnimatedTimer.visible = false
	$AnimatedTimer.playing = false
	$AnimatedTimer.frame = 0
	
	MusicManager.music_on_play()


func _input(event):
	
	if not in_game:
		return
	if win_gui_visible:
		return
		
	if event.is_action_pressed("ui_cancel"):
		if game_in_pause:
			if $TimerRestorePause.time_left > 0:
				pause()
				$SoundManager.stop_all_sfx()
				all_propulsion_pause()
				$TimerRestorePause.stop()
				if pause_menu == null:
					pause_menu = PauseMenu.instance()
					add_child(pause_menu)
			
			elif pause_menu != null:
				if pause_menu.go_to_main_menu == true:
					return
				else:
					Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
					pause_menu.play_out()
		else:
			pause()
			if pause_menu == null:
				pause_menu = PauseMenu.instance()
				add_child(pause_menu)
			

func _on_TimerRestorePause_timeout():
	play()
	


func _on_AnimatedTimer_animation_finished():
	$AnimatedTimer.visible = false
	$AnimatedTimer.frame = 0


func _on_TimerTransition_timeout():
	$TimerRestorePause.start()
	$SoundManager.play_sfx("Countdown")
	$AnimatedTimer.frame = 0
	$AnimatedTimer.visible = true
	$AnimatedTimer.playing = true
