extends Node2D

var pause_menu_scene = preload("res://interfaces/menuPausa.tscn")
var pause_menu_instance = null

func _ready() -> void:
	LevelManager.start_floor()


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			if pause_menu_instance:
				pause_menu_instance.queue_free()
		else:
			get_tree().paused = true
			pause_menu_instance = pause_menu_scene.instantiate()
			add_child(pause_menu_instance)
