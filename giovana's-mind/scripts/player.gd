extends CharacterBody2D

@export var move_speed: float = 200.0
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.4

@onready var damage_indicator = get_tree().get_root().find_child("DamageIndicator", true, false)

var can_shoot := true

# --- ESTADO DA ANIMAÇÃO ---
@onready var sprite_animado: AnimatedSprite2D = $SpriteAnimado

@onready var muzzle_cima: Marker2D = $SpriteAnimado/MuzzleCima
@onready var muzzle_baixo: Marker2D = $SpriteAnimado/MuzzleBaixo
@onready var muzzle_direita: Marker2D = $SpriteAnimado/MuzzleDireita

# Troca de urso
@onready var swap_cooldown_timer: Timer = $SwapCooldownTimer
var can_swap_arma: bool = true

# Controla a cor da arma atual: "azul" ou "roxo"
var estado_arma: String = "azul"

# --- ATRIBUTOS DAS ARMAS ---
@export_group("Arma Azul")
@export var azul_dano: int = 1
@export var azul_speed: float = 600.0
@export var azul_range: float = 9999.0 # Alcance "infinito"
@export var azul_fire_rate: float = 0.6

@export_group("Arma Roxa")
@export var roxo_dano: int = 3
@export var roxo_speed: float = 450.0 # Mesma velocidade
@export var roxo_range: float = 350.0 # Alcance curto
@export var roxo_fire_rate: float = 1.2 # Cooldown maior
@export var roxo_scale: Vector2 = Vector2(1, 1) # 50% maior

# Guarda a última direção para a animação "parado"
var direcao_parado: String = "_baixo" # Começa olhando para baixo
var direcao_animacao_atual: String = "_baixo"
	
# Guarda se o sprite estava espelhado (para "parado_esquerda")
var ultimo_flip_h: bool = false

# ❤️ VIDA FRACIONADA (¼ = 1 unidade)
var hearts: int = 3                # quantidade de corações
var max_health: int = hearts * 4   # 4 unidades = 1 coração
var current_health: int = max_health
var is_dead: bool = false


# ---------- VIDA ----------
func take_damage(amount: int = 1) -> void:
	if damage_indicator:
		damage_indicator.play_damage_effect()
	if is_dead:
		return

	current_health -= amount
	

	if current_health <= 0:
		current_health = 0
		die()

	print("Vida:", current_health, "/", max_health)


func heal(amount: int = 1) -> void:
	if is_dead:
		return

	current_health += amount

	if current_health > max_health:
		current_health = max_health

	print("Vida:", current_health, "/", max_health)


func die() -> void:
	is_dead = true
	print("Player morreu!")
	# Aqui você pode adicionar animação, game over, etc.


# ---------- MOVIMENTO ----------
func _physics_process(delta: float) -> void:
	
	# --- 1. LEITURA DE INPUT (MOVIMENTO) ---
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1

	# --- 2. LEITURA DE INPUT (TIRO) ---
	# NOTA: Movemos isso para o início!
	var shoot_dir = get_shoot_direction()

	# --- 3. LÓGICA DE ANIMAÇÃO ---
	var prefixo_movimento: String
	var sufixo_direcao: String
	
	# Esta variável decide PARA ONDE VAMOS OLHAR
	var facing_vector: Vector2 = Vector2.ZERO

	# PRIORIDADE 1: Se está atirando, olhe para a direção do tiro
	if shoot_dir.length() > 0:
		facing_vector = shoot_dir
	# PRIORIDADE 2: Se não está atirando mas está andando, olhe para onde anda
	elif input_vector.length() > 0:
		facing_vector = input_vector
	
	# ----- ESTADO: ANDANDO ou PARADO? -----
	# A animação é de "andar" se o 'input_vector' (movimento) for maior que 0
	if input_vector.length() > 0:
		prefixo_movimento = "andar"
	else:
		prefixo_movimento = "parada"

	# ----- DIRECÃO DA ANIMAÇÃO (baseado no facing_vector) -----
	# Se 'facing_vector' for diferente de zero, atualizamos a direção
	if facing_vector.length() > 0:
		# Prioriza o movimento horizontal para animação
		if facing_vector.x != 0:
			sufixo_direcao = "_direita"
			direcao_parado = "_direita" # Salva para quando parar
			
			# Vira o sprite para a esquerda
			sprite_animado.flip_h = (facing_vector.x < 0)
			
		elif facing_vector.y < 0:
			sufixo_direcao = "_cima"
			direcao_parado = "_cima"
			sprite_animado.flip_h = false # Cima/Baixo não são espelhados
			
		elif facing_vector.y > 0:
			sufixo_direcao = "_baixo"
			direcao_parado = "_baixo"
			sprite_animado.flip_h = false
			
		# Salva o último estado do flip
		ultimo_flip_h = sprite_animado.flip_h
		
	else:
		# ----- ESTADO: PARADO (e sem atirar) -----
		# (O prefixo_movimento já é "parada")
		sufixo_direcao = direcao_parado # Usa a última direção que estávamos
		
		# Se a última direção foi "direita", aplica o último flip
		if sufixo_direcao == "_direita":
			sprite_animado.flip_h = ultimo_flip_h
		else:
			sprite_animado.flip_h = false
	
	direcao_animacao_atual = sufixo_direcao	
	# --- 4. MONTAGEM DO NOME DA ANIMAÇÃO ---
	var anim_name: String
	
	# Caso especial: Cima não tem cor (baseado na sua lista)
	if sufixo_direcao == "_cima":
		anim_name = prefixo_movimento + sufixo_direcao
	else:
		# Montagem padrão: ex: "andar" + "_direita" + "_azul"
		anim_name = prefixo_movimento + sufixo_direcao + "_" + estado_arma
		
	# --- 5. TOCA A ANIMAÇÃO ---
	# Só toca a animação se ela for diferente da atual
	if sprite_animado.animation != anim_name:
		sprite_animado.play(anim_name)

	# --- 6. APLICA MOVIMENTO ---
	# NOTA: O movimento AINDA USA 'input_vector' (isso é o correto)
	input_vector = input_vector.normalized()
	velocity = input_vector * move_speed
	move_and_slide()

	# --- 7. LÓGICA DE TIRO ---
	# 'shoot_dir' já foi calculado lá em cima
	if shoot_dir != Vector2.ZERO and can_shoot:
		shoot(shoot_dir)
		
	# --- 8. LÓGICA DE TROCA DE ARMA ---
	if Input.is_action_just_pressed("trocar_arma") and can_swap_arma:
		can_swap_arma = false
		swap_cooldown_timer.start()

		# 2. Troca a arma
		if estado_arma == "azul":
			estado_arma = "roxo"
		else:
			estado_arma = "azul"

	# 3. Força a atualização da animação (opcional, mas bom)
	# Pega o nome da animação atual e troca a cor
	var anim_atual = sprite_animado.animation.split("_")
	if anim_atual.size() > 1: # Previne erro se a animação não tiver cor
		anim_atual[anim_atual.size()-1] = estado_arma
		sprite_animado.play(str(anim_atual).replace(" ", "").replace("[", "").replace("]", "").replace(",", "_"))


func get_shoot_direction() -> Vector2:
	var dir = Vector2.ZERO

	if Input.is_action_pressed("shoot_up"):
		dir.y -= 1
	if Input.is_action_pressed("shoot_down"):
		dir.y += 1
	if Input.is_action_pressed("shoot_left"):
		dir.x -= 1
	if Input.is_action_pressed("shoot_right"):
		dir.x += 1

	return dir.normalized()


func shoot(direction: Vector2):
	can_shoot = false
	
	var bullet = bullet_scene.instantiate()
	var spawn_position: Vector2
	
	# --- Lógica do Muzzle (sem alterações) ---
	match direcao_animacao_atual:
		"_cima":
			spawn_position = muzzle_cima.global_position
		"_baixo":
			spawn_position = muzzle_baixo.global_position
		"_direita":
			if sprite_animado.flip_h:
				var local_pos = muzzle_direita.position
				local_pos.x *= -1
				spawn_position = sprite_animado.to_global(local_pos)
			else:
				spawn_position = muzzle_direita.global_position
		_:
			spawn_position = muzzle_direita.global_position

	# --- CONFIGURAÇÃO DA BALA (AQUI ESTÁ A MÁGICA) ---
	bullet.global_position = spawn_position
	bullet.direction = direction
	bullet.cor_arma = estado_arma 
	
	var current_fire_rate: float
	
	if estado_arma == "azul":
		bullet.dano = azul_dano
		bullet.speed = azul_speed
		bullet.range = azul_range # Passa o alcance para a bala
		current_fire_rate = azul_fire_rate
	else: # Roxo
		bullet.dano = roxo_dano
		bullet.speed = roxo_speed
		bullet.range = roxo_range # Passa o alcance para a bala
		bullet.scale = roxo_scale # Define o tamanho
		current_fire_rate = roxo_fire_rate
	
	get_tree().current_scene.add_child(bullet)

	# Usa o cooldown correto
	await get_tree().create_timer(current_fire_rate).timeout
	can_shoot = true
	
func aplicar_buff_velocidade(multiplicador: float = 1.2):
	# Aumenta a velocidade de movimento em 20%
	move_speed *= multiplicador
	print("Velocidade aumentada! Nova velocidade: ", move_speed)

func aplicar_buff_dano(dano_extra: int = 1):
	# Aumenta o dano das duas armas
	azul_dano += dano_extra
	roxo_dano += dano_extra
	print("Dano aumentado! Novo dano azul: ", azul_dano)

func aplicar_buff_cooldown(multiplicador: float = 0.8):
	# Reduz o cooldown em 20% (multiplica por 0.8)
	azul_fire_rate *= multiplicador
	roxo_fire_rate *= multiplicador
	print("Cooldown reduzido! Novo fire rate azul: ", azul_fire_rate)

func _on_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.


func _on_swap_cooldown_timer_timeout():
	can_swap_arma = true
