extends Area2D

@export var speed: float = 600.0
@export var dano: int = 1 
var direction: Vector2

var cor_arma: String = "azul" 
@onready var sprite_animado: AnimatedSprite2D = $SpriteAnimado

var acertou: bool = false

func _ready():
	sprite_animado.play("disparo_" + cor_arma)

func _physics_process(delta):
	if acertou:
		return
		
	position += direction * speed * delta

# --- LÓGICA DE EXPLOSÃO CENTRALIZADA ---

func explodir():
	# Se já chamamos explodir(), não faça de novo
	if acertou:
		return
		
	acertou = true
	speed = 0 # Para a bala imediatamente
	sprite_animado.play("acertou_" + cor_arma)
	
	# Desativa a colisão da bala para ela não acertar várias coisas
	$CollisionShape2D.set_deferred("disabled", true)

# --- SINAIS DE COLISÃO ---

# Detecta ÁREAS (ex: Hitbox do Inimigo)
func _on_area_entered(area):
	if acertou:
		return
		
	# 1. Verifica se é um inimigo
	if area.is_in_group("inimigo"):
		# 2. Causa dano
		area.get_parent().receber_dano(dano)
		# 3. Explode
		explodir()
		
# Detecta CORPOS FÍSICOS (ex: Paredes, Chão, o Player)
func _on_body_entered(body):
	if acertou:
		return

	# 1. Verifica se o corpo é um inimigo
	if body.is_in_group("inimigo"):
		
		# 2. Causa dano
		# (O script está no próprio CharacterBody2D, então chamamos direto)
		body.receber_dano(dano)
		
		# 3. Explode
		explodir()

	# 4. Se não for inimigo, verifica se é o player
	elif not body.is_in_group("player"):
		
		# 5. Explode (em qualquer parede ou obstáculo)
		explodir()

# --- SINAIS DE CONTROLE ---

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_sprite_animado_animation_finished():
	var anim_atual = sprite_animado.animation
	
	if anim_atual == "disparo_" + cor_arma:
		sprite_animado.play("normal_" + cor_arma)
		
	elif anim_atual == "acertou_" + cor_arma:
		queue_free() # Remove a bala após a explosão
