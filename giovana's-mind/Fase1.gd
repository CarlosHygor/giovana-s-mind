extends Node2D

@onready var camera = $Camera2D
@onready var player = $player

func on_camera_zone_body_entered(body,zone: Area2D):
	if not body.is_in_group("player"):
		return
	camera.global_position
