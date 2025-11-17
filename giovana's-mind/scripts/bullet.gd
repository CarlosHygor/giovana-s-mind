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
	sprite_animado.play("disparo_" + cor_arma)

func _physics_process(delta):
	if acertou:
		return
		
	# 1. ROTAÇÃO DA BALA
	rotation = direction.angle()
	
	# CORREÇÃO: Se a bala estiver indo para a esquerda (rotação > 90 graus),
	# invertemos o eixo Y para o desenho não ficar de cabeça para baixo.
	if abs(rotation) > PI / 2:
		# ...Invertemos a escala Y APENAS DO SPRITE.
		# Isso faz o desenho desvirar, mas mantendo a proporção original.
		sprite_animado.scale.y = -1
	else:
		# Se estiver para a direita, escala normal.
		sprite_animado.scale.y = 1
	
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
	
	# Ignora a detection zone (para não explodir no "olho" do inimigo)
	if area.name == "DetectionZone":
		return

	# Lógica de quem atirou
	if sou_do_inimigo:
		# Bala do Inimigo acertando Hitbox do Player (se tiver)
		if area.is_in_group("player_hitbox"):
			area.get_parent().take_damage(dano)
			explodir()
			
	else:
		# --- AQUI ESTÁ O SEGREDO PARA O SEU CASO ---
		# Bala do Player acertando Hitbox do Inimigo
		if area.is_in_group("inimigo"):
			
			# 1. Pega o PAI da hitbox (que é o Inimigo.gd)
			var inimigo = area.get_parent()
			
			# 2. Chama a função no PAI
			if inimigo.has_method("receber_dano"):
				inimigo.receber_dano(dano)
				
			explodir()

# --- SINAIS DE CONTROLE ---

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
