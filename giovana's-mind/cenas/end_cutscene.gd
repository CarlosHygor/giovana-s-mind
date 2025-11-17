extends Node2D

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	animation_player.play("show_end")

func _go_to_menu():
	get_tree().change_scene_to_file("res://interfaces/telaInicial.tscn")
