extends Area2D

signal player_triggered


@onready var sprite = $Sprite

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	open_door()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_triggered.emit()

func close_door():
	$Blocker/PhysicalCollision.disabled = false

func open_door():
	$Blocker/PhysicalCollision.disabled = true

func hide_door():
	visible = false
	$TriggerCollision.disabled = true
	$Blocker/PhysicalCollision.disabled = true
