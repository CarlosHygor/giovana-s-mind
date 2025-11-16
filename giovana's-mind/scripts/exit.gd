extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		$ColisionShape2D.disabled = true
		LevelManager.go_to_next_floor()
