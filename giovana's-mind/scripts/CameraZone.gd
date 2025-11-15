extends Area2D

var main_script = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	main_script = get_tree().get_root().find_child("Main",true,false)

func _on_body_entered(body):
	if not main_script:
		print("erro")
		return
	if body.is_in_group("player"):
		main_script.move_camera_to(self.global_position)
