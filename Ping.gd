extends Node2D

onready var _animation := $AnimationPlayer

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
