extends Node



var animation_finished := false

var transition_visibility := false


func _ready():
	pass


func set_visibility(vis):
	transition_visibility = vis
	$Transition.visible = vis
	$Transition2.visible = vis
	$Transition3.visible = vis
	$Transition4.visible = vis


func play_transition_out():
	$AnimationPlayer.play("transition_in_01_anim")

func play_transition_in():
	$AnimationPlayer.play("transition_out_anim")

func _on_AnimationPlayer_animation_finished(_anim_name):
	animation_finished = true

