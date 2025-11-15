extends Node2D

@onready var camera = $Camera2D
@onready var player = $player



func _on_camera_zone_body_entered(body, zone: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	camera.global_position = zone.global_position

func move_camera_to(new_posirion : Vector2):
	camera.global_position = new_posirion
