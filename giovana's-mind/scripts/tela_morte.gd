extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_jogar_3_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/world.tscn")


func _on_jogar_4_pressed() -> void:
	get_tree().change_scene_to_file("res://interfaces/telaInicial.tscn")
