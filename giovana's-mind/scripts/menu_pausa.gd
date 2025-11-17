extends CanvasLayer

var settings_scene = preload("res://interfaces/telaMenuPause.tscn")
@onready var main_buttons = $Control/Panel/BoxContainer/VBoxContainer

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if main_buttons.visible:
			get_viewport().set_input_as_handled()
			_on_jogar_pressed()

func _on_jogar_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_menu_pressed() -> void:
	var settings_instance = settings_scene.instantiate()
	add_child(settings_instance)
	main_buttons.visible = false

func _on_sair_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://interfaces/telaInicial.tscn")

func show_pause_buttons():
	main_buttons.visible = true
