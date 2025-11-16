extends Button

@export var scale_hover: float = 1.1
@export var duracao_animacao: float = 0.2

var tween: Tween

func _ready():
	pivot_offset = size / 2.0
	scale = Vector2(1.0, 1.0)
	
	mouse_entered.connect(_on_mouse_entrou)
	mouse_exited.connect(_on_mouse_saiu)

func _on_mouse_entrou():
	if tween:
		tween.kill()
		
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	var scale_vector = Vector2(scale_hover, scale_hover)
	tween.tween_property(self, "scale", scale_vector, duracao_animacao)

func _on_mouse_saiu():
	if tween:
		tween.kill()
		
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), duracao_animacao)
