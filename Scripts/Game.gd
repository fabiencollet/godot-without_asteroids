extends Node2D


export (PackedScene) var WinGui
export (PackedScene) var Players

var players_are_init := false

onready var win_gui = WinGui.instance()
var win_gui_visible: = false

func _ready():
	$Background.visible = false
	$Transition.set_visibility(true)
	$Transition.play_transition_in()
	$TimerInitPlayer.start()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	add_child(win_gui)
	win_gui.visible = false


func _process(_delta):
	
	if not players_are_init:
		return
		
	if $Players_grp/Players.check_for_winner() and win_gui.visible == false:
		round_finish()


func reset_winner_gui():
	
	win_gui.visible = false
	win_gui_visible = false


func update_all_score_in_gui():
	
	for player in $Players_grp/Players.players_list:
		win_gui.update_player_score(player.name, player.score)


func round_finish():
	
	var list_winner: = []
	var txt: = ""
	for player in $Players_grp/Players.players_list:
		if player.visible:
			list_winner.append(player)
	
	if list_winner:
		txt = list_winner[0].name + " Win The Round !!"
		for winner in list_winner:
			winner.score += 1
	
	else:
		txt = "Draw !!"
	
	win_gui.label.text = txt
	update_all_score_in_gui()
	$TimerWin.start()
	win_gui.play_animation_in()
	win_gui.visible = true
	win_gui_visible = true


func _on_TimerWin_timeout():
	get_node("TimerWin").stop()
	
	for player in $Players_grp/Players.players_list:
		if player.score >= Globals.nb_rounds_to_win:
			Globals.set_winner(player.name)
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://Scenes/game_win_gui.tscn")
			return
	
	
	reset_winner_gui()
	$Players_grp/Players.reset_players()


func _on_TimerInitPlayer_timeout():
	$Background.visible = true
	
	var players = Players.instance()
	players.in_game = true
	$Players_grp.add_child(players)
	players_are_init = true
	
	var players_list = $Players_grp/Players.players_list
	
	win_gui.visible = true
	for player in players_list:
		win_gui.add_score_widget(player.name)
	win_gui.visible = false
	
	win_gui.set_max_victory(Globals.nb_rounds_to_win)
	
	$Players_grp/Players/TimerTransition.start()
