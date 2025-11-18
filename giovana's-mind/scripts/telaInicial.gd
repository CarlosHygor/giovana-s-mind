extends Control

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer

func _ready():
	if not Globais.intro_tocou:
		video_player.finished.connect(_on_video_finished)
		video_player.play()
	else:
		video_player.visible = false
		video_player.queue_free()

func _on_video_finished():
	Globais.intro_tocou = true
	
	video_player.visible = false
	video_player.queue_free()

func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/world.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://interfaces/telaMenu.tscn")

func _on_sair_pressed() -> void:
	get_tree().quit()
