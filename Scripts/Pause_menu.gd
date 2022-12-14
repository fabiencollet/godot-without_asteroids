extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var resume := false
var go_to_main_menu := false
onready var b_dummy: Button = get_node("B_Dummy")
onready var b_resume: Button = get_node("CenterContainer/VBoxContainer/B_Resume")
onready var b_main_menu: Button = get_node("CenterContainer/VBoxContainer/B_Main_Menu")
# Called when the node enters the scene tree for the first time.
func _ready():
	go_to_main_menu = false
	$AnimationPlayer.play("Anim_in")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(Globals.arrow)
	pass # Replace with function body.


func disable_buttons():
	$CenterContainer/VBoxContainer/B_Resume.disabled = true
	$CenterContainer/VBoxContainer/B_Main_Menu.disabled = true
	
func play_out():
	disable_buttons()
	$AnimationPlayer.play("Anim_out")
	$TimerResume.start()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _on_B_Main_Menu_pressed():
	disable_buttons()
	go_to_main_menu = true
	$Transition.play_transition_out()
	$TimerMainMenu.start()
	$AnimationPlayer.play("Anim_out")


func _on_TimerMainMenu_timeout():
	var _error = get_tree().change_scene("res://Scenes/main_menu.tscn")


func _on_B_Resume_pressed():
	play_out()


func _on_TimerResume_timeout():
	resume = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Anim_in":
		$CenterContainer/VBoxContainer/B_Resume.grab_focus()


func _on_B_Resume_mouse_exited():
	b_dummy.grab_focus()


func _on_B_Resume_mouse_entered():
	b_resume.grab_focus()


func _on_B_Main_Menu_mouse_entered():
	b_main_menu.grab_focus()


func _on_B_Main_Menu_mouse_exited():
	b_dummy.grab_focus()
