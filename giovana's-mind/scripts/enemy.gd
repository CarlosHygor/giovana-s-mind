extends CharacterBody2D

# --- Variáveis de Atributos ---
@export var move_speed: float = 75.0
@export var fire_rate: float = 1.5
@export var bullet_scene: PackedScene

# --- Referências dos Nós ---
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_zone: Area2D = $DetectionZone
@onready var patrol_timer: Timer = $PatrolTimer
@onready var fire_rate_timer: Timer = $FireRateTimer

# --- Referências dos Muzzles (NOVOS) ---
@onready var muzzle_cima: Marker2D = $AnimatedSprite2D/MuzzleCima
@onready var muzzle_baixo: Marker2D = $AnimatedSprite2D/MuzzleBaixo
@onready var muzzle_direita: Marker2D = $AnimatedSprite2D/MuzzleDireita

# --- Variáveis de Estado ---
var player_node: Node2D = null
var current_move_direction: Vector2 = Vector2.DOWN
var can_shoot: bool = true

# Guarda qual muzzle usar no momento do tiro
var muzzle_atual: Marker2D

# Array com as 4 direções cardinais
const MOVE_DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]


func _ready():
	detection_zone.body_entered.connect(_on_detection_zone_body_entered)
	detection_zone.body_exited.connect(_on_detection_zone_body_exited)
	patrol_timer.timeout.connect(_on_patrol_timer_timeout)
	fire_rate_timer.timeout.connect(_on_fire_rate_timer_timeout)
	
	pick_random_direction()
	# Define um muzzle inicial para evitar erros
	muzzle_atual = muzzle_baixo 


func _physics_process(delta):
	var direcao_olhar: Vector2 = Vector2.ZERO

	if player_node:
		# --- ESTADO DE ATAQUE ---
		velocity = Vector2.ZERO
		
		# Calcula a direção para o player (para saber para onde olhar/atirar)
		direcao_olhar = (player_node.global_position - global_position).normalized()
		
		# Atualiza a animação e o muzzle baseado em onde o player está
		atualizar_animacao_e_muzzle(direcao_olhar)
		
		if can_shoot:
			shoot_at_player(direcao_olhar)
			
	else:
		# --- ESTADO DE PATRULHA ---
		velocity = current_move_direction * move_speed
		direcao_olhar = current_move_direction
		
		# Atualiza a animação baseado no movimento
		atualizar_animacao_e_muzzle(direcao_olhar)
	
	move_and_slide()
	
	# Colisão com paredes (Patrulha)
	var collision = get_last_slide_collision()
	if collision and not player_node:
		current_move_direction = current_move_direction.bounce(collision.get_normal()).normalized()


# --- NOVA FUNÇÃO: Controla Animação e Escolhe o Muzzle ---
func atualizar_animacao_e_muzzle(dir: Vector2):
	# Prioriza movimento horizontal (Esquerda/Direita)
	if abs(dir.x) > abs(dir.y):
		anim_sprite.play("lado")
		muzzle_atual = muzzle_direita
		
		if dir.x < 0:
			anim_sprite.flip_h = true # Esquerda (flipado)
		else:
			anim_sprite.flip_h = false # Direita (normal)
			
	# Movimento Vertical
	else:
		anim_sprite.flip_h = false # Nunca flipa verticalmente
		
		if dir.y < 0:
			anim_sprite.play("costas") # Cima
			muzzle_atual = muzzle_cima
		else:
			anim_sprite.play("frente") # Baixo
			muzzle_atual = muzzle_baixo


func shoot_at_player(shoot_dir: Vector2):
	can_shoot = false
	fire_rate_timer.start(fire_rate)
	
	var bullet = bullet_scene.instantiate()
	
	# --- 1. CALCULAR A POSIÇÃO (spawn_pos) ---
	var spawn_pos: Vector2
	
	# Se estiver olhando para a esquerda (flipado) e usando o muzzle lateral
	if anim_sprite.flip_h and muzzle_atual == muzzle_direita:
		# Pega a posição local, inverte o X e converte para global
		var local_pos = muzzle_direita.position
		local_pos.x *= -1
		spawn_pos = anim_sprite.to_global(local_pos)
	else:
		# Caso normal (Cima, Baixo ou Direita Normal)
		spawn_pos = muzzle_atual.global_position
	# -----------------------------------------

	# --- 2. APLICAR POSIÇÃO E DIREÇÃO ---
	bullet.global_position = spawn_pos
	bullet.direction = shoot_dir 
	
	# --- 3. CONFIGURAÇÃO DA BALA INIMIGA ---
	bullet.sou_do_inimigo = true     # Diz que é do mal
	bullet.cor_arma = "inimigo"     
	bullet.dano = 1                  
	bullet.speed = 250.0             
	bullet.range = 9999.9 
	
	get_parent().add_child(bullet)


func pick_random_direction():
	current_move_direction = MOVE_DIRECTIONS.pick_random()
	

# --- Callbacks ---
func _on_detection_zone_body_entered(body):
	if body.is_in_group("player"):
		player_node = body
		patrol_timer.stop()

func _on_detection_zone_body_exited(body):
	if body == player_node:
		player_node = null
		patrol_timer.start()
		pick_random_direction() # Já muda de direção para não ficar parado olhando pro nada

func _on_patrol_timer_timeout():
	pick_random_direction()

func _on_fire_rate_timer_timeout():
	can_shoot = true
