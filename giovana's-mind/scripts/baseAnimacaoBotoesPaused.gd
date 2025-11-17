extends Control

@onready var volume_slider = $volume/HSlider
@onready var percentage_label = $volume/porcentagem

var master_bus_index = AudioServer.get_bus_index("Master")

func _ready():
	volume_slider.min_value = 0.1
	volume_slider.max_value = 100.0
	volume_slider.step = 1.0
	
	var current_db = AudioServer.get_bus_volume_db(master_bus_index)
	var current_linear = db_to_linear(current_db)
	
	volume_slider.value = current_linear * 100.0
	
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	
	_update_percentage_label(volume_slider.value)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_voltar_pressed()

func _on_volume_slider_value_changed(slider_value: float):
	var linear_value = slider_value / 100.0
	
	var db
	if linear_value == 0.0:
		db = -80.0
	else:
		db = linear_to_db(linear_value)
	
	AudioServer.set_bus_volume_db(master_bus_index, db)
	
	_update_percentage_label(slider_value)

func _update_percentage_label(value: float):
	percentage_label.text = "%d%%" % round(value)

func _on_button_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		$"tela cheia/selecionado".visible = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		$"tela cheia/selecionado".visible = false

func _on_voltar_pressed():
	if get_parent() and get_parent().has_method("show_pause_buttons"):
		get_parent().show_pause_buttons()
	queue_free()
