extends Node2D 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var winner := ""

var nb_players := 2
var min_players := 2
var max_players := 4

var master_volume = 0
var music_volume = 0
var sfx_volume = 0

var nb_rounds_to_win := 5

var arrow = load("res://Assets/Menu/cursor.png")

onready var screen_size = get_viewport_rect().size

var list_game_mode = ["Classic", "Boost Off"]

var game_mode = list_game_mode[0]

# Called when the node enters the scene tree for the first time.
func set_winner(name):
	winner = name


func reset_winner():
	winner = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
