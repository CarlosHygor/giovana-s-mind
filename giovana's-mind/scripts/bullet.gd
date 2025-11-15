extends Area2D

@export var speed: float = 600.0
var direction: Vector2

func _physics_process(delta):
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area):
	queue_free()
