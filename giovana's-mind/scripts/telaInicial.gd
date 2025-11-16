extends Control

func _ready():
	pass

func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/world.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://interfaces/telaMenu.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()
