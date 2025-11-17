extends Area2D

@export var speed: float = 600.0
@export var dano: int = 1
var direction: Vector2

# --- Variáveis de Controle ---
var range: float = 9999.0 
var distance_traveled: float = 0.0
var sou_do_inimigo: bool = false 
var cor_arma: String = "azul" 

@onready var sprite_animado: AnimatedSprite2D = $SpriteAnimado
var acertou: bool = false

func _ready():
	# 1. GARANTE QUE A BALA APAREÇA NA FRENTE DE TUDO (Player, Inimigos, Chão)
	z_index = 10 
	
	# Toca a animação de disparo correta
	sprite_animado.play("disparo_" + cor_arma)

func _physics_process(delta):
	if acertou:
		return
		
	# 1. ROTAÇÃO DA BALA
	rotation = direction.angle()
	
	# --- CORREÇÃO VISUAL ---
	# Em vez de mexer no 'scale' da bala inteira (que deforma ela),
	# nós apenas flipamos o DESENHO (sprite) verticalmente.
	
	# Se a rotação for maior que 90 graus (olhando para esquerda), flipa V.
	sprite_animado.flip_v = (abs(rotation) > PI / 2)
	# -----------------------
	
	# 2. MOVIMENTO
	var move_vec = direction * speed * delta
	position += move_vec
	
	distance_traveled += move_vec.length()
	
	if distance_traveled >= range:
		explodir()

# --- LÓGICA DE EXPLOSÃO ---
func explodir():
	if acertou:
		return
		
	acertou = true
	speed = 0
	
	# Toca a animação de explosão correta
	sprite_animado.play("acertou_" + cor_arma)
	
	# Desativa a colisão
	$CollisionShape2D.set_deferred("disabled", true)

# --- SINAIS (Mantenha os seus como estão) ---
# ... (Seus códigos de _on_body_entered e _on_area_entered continuam iguais) ...

# --- REMOVER APÓS ANIMAÇÃO ---
func _on_sprite_animado_animation_finished():
	var anim_atual = sprite_animado.animation
	
	# Se a animação de explosão acabou, deleta a bala
	if anim_atual == "acertou_" + cor_arma:
		queue_free()
# Detecta CORPOS FÍSICOS (ex: Paredes, Chão, o Player)
func _on_body_entered(body):
	if acertou:
		return

	# --- LÓGICA DA BALA DO INIMIGO ---
	if sou_do_inimigo:
		# Se sou do inimigo, quero acertar o PLAYER
		if body.is_in_group("player"):
			body.take_damage(dano) # O Player tem a função take_damage
			explodir()
		
		# Se bater na parede (e não for outro inimigo)
		elif not body.is_in_group("inimigo"):
			explodir()

	# --- LÓGICA DA BALA DO PLAYER ---
	else:
		# Se sou do player, quero acertar o INIMIGO
		if body.is_in_group("inimigo"):
			# Verifica se o inimigo tem a função receber_dano (ou take_damage)
			if body.has_method("receber_dano"):
				body.receber_dano(dano)
			explodir()

		# Se não for player (para não se acertar), explode na parede
		elif not body.is_in_group("player"):
			explodir()


# Detecta ÁREAS (Hitboxes separadas)
func _on_area_entered(area):
	if acertou:
		return
		
	# Mesma lógica acima, mas para Areas
	if sou_do_inimigo:
		if area.is_in_group("player_hitbox"): # Caso use hitbox separada
			area.get_parent().take_damage(dano)
			explodir()
	else:
		if area.is_in_group("inimigo"):
			area.get_parent().receber_dano(dano)
			explodir()

# --- SINAIS DE CONTROLE ---

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
