extends Panel


export (PackedScene) var Players

var players_are_init := false
var respawnable: = true 

onready var label_victory := get_node("CenterContainer/PlayerBody2/VBoxContainer/HBoxContainer/LabelVictory")
onready var label_player := get_node("CenterContainer/PlayerBody3/VBoxContainer/HBoxContainer/LabelPlayer")
onready var label_mode := get_node("CenterContainer/PlayerBody5/VBoxContainer/HBoxContainer/LabelMode")
onready var label_music := get_node("CenterContainer/PlayerBody6/VBoxContainer/HBoxContainer/LabelVolume")
onready var label_sfx := get_node("CenterContainer/PlayerBody6/VBoxContainer/HBoxContainer2/LabelSFXValue")
onready var slider_music := get_node("CenterContainer/PlayerBody6/VBoxContainer/HBoxContainer/HSlider")
onready var slider_sfx := get_node("CenterContainer/PlayerBody6/VBoxContainer/HBoxContainer2/HSlider_SFX")

var nb_game_mode = len(Globals.list_game_mode)
var game_mode_id = 0


func _ready():
	set_game_mode_label()
	$Transition.set_visibility(true)
	$Transition.play_transition_in()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(Globals.arrow)
	$TimerInitPlayer.start()
	set_label_victory()
	set_label_players()
	
	set_audio_slider_ui()
	MusicManager.music_on_play()


func _process(_delta):
	if not players_are_init:
		return
	if $Players_grp/Players.all_players_dead() and respawnable:
		respawnable = false
		$TimerResetPlayer.start()
	


func _on_TimerResetPlayer_timeout():
	respawnable = true
	$Players_grp/Players.reset_players(false)
	$TimerResetPlayer.stop()


func _on_TimerLaunchGame_timeout():
	var _error = get_tree().change_scene("res://Scenes/game.tscn")


func _on_TimerInitPlayer_timeout():
	var players = Players.instance()
	players.in_game = false
	$Players_grp.add_child(players)
	players_are_init = true
	$CenterContainer.visible = true
	$TimerMenuAnimation.start()


func _on_B_Play_pressed():
	$AnimationPlayer.play("Anim_out_to_play")
	$CenterContainer/PlayerBody/B_Play.disabled = true


func set_label_victory():
	label_victory.text = str(Globals.nb_rounds_to_win)

func set_label_players():
	label_player.text = str(Globals.nb_players)

func _on_B_min_win_pressed():
	if Globals.nb_rounds_to_win > 1:
		Globals.nb_rounds_to_win -= 1
		set_label_victory()


func _on_B_plus_win_pressed():
	if Globals.nb_rounds_to_win < 15:
		Globals.nb_rounds_to_win += 1
		set_label_victory()


func refresh_players():
	
	$Players_grp.remove_child($Players_grp.get_child(0))
	
	var players = Players.instance()
	players.in_game = false
	$Players_grp.add_child(players)


func _on_B_min_player_pressed():
	if Globals.nb_players > 2 :
		#$Players_grp/Players.remove_player()
		Globals.nb_players -= 1
		#$Players_grp/Players.refresh_players()
		refresh_players()
		set_label_players()

func _on_B_plus_player_pressed():
	if Globals.nb_players < 4 :
		#$Players_grp/Players.add_player()
		Globals.nb_players += 1
		#$Players_grp/Players.refresh_players()
		refresh_players()
		var last_player = $Players_grp/Players.players_list[Globals.nb_players-1]
		last_player.shield_on()
		last_player.shield_off()	
		
		set_label_players()
	


func _on_TimerQuit_timeout():
	get_tree().quit()


func _on_B_Quit_focus_exited():
	$AnimationPlayer.play("Anim_out_to_quit")
	$CenterContainer/PlayerBody4/B_Quit.disabled = true
	$CenterContainer/PlayerBody4/B_Quit.grab_focus()

func _on_B_Play_focus_exited():
	$AnimationPlayer.play("Anim_out_to_play")
	$CenterContainer/PlayerBody/B_Play.disabled = true
	$CenterContainer/PlayerBody/B_Play.grab_focus()

func _on_TimerMenuAnimation_timeout():
	$AnimationPlayer.play("Anim_in")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Anim_out_to_quit":
		$TimerQuit.start()
		$Transition.play_transition_out()
	elif anim_name == "Anim_out_to_play":
		$TimerLaunchGame.start()
		$Transition.play_transition_out()

func set_game_mode_label():
	label_mode.text = Globals.list_game_mode[game_mode_id]
	Globals.game_mode = Globals.list_game_mode[game_mode_id]

		
func _on_B_min_mode_pressed():
	game_mode_id -= 1
	if game_mode_id < 0:
		game_mode_id = nb_game_mode-1
	set_game_mode_label()

func _on_B_plus_mode_pressed():
	game_mode_id += 1
	if game_mode_id > nb_game_mode-1:
		game_mode_id = 0
	set_game_mode_label()

func set_audio_slider_ui():
	label_music.text = str(Globals.music_volume)
	label_sfx.text = str(Globals.sfx_volume)
	slider_music.value = Globals.music_volume
	slider_sfx.value = Globals.sfx_volume
	slider_music.focus_mode = 0
	slider_sfx.focus_mode = 0

func set_master_volume(_value):
	pass

func set_music_volume(value):
	label_music.text = str(value)
	Globals.music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)

func set_sfx_volume(value):
	label_sfx.text = str(value)
	Globals.sfx_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)

func _on_HSlider_value_changed(value):
	set_music_volume(value)
	slider_music.focus_mode = 0

func _on_HSlider_SFX_value_changed(value):
	set_sfx_volume(value)
	slider_sfx.focus_mode = 0

func _on_B_Quit_pressed():
	$AnimationPlayer.play("Anim_out_to_quit")
	$CenterContainer/PlayerBody4/B_Quit.disabled = true
