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

# Controla a cor da arma atual: "azul" ou "roxo"
var estado_arma: String = "azul"

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

	if current_health < 0:
		current_health = 0

	print("Vida:", current_health, "/", max_health)

	if current_health == 0:
		die()


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
	
	# Lemos a direção da ANIMAÇÃO que o _physics_process salvou
	match direcao_animacao_atual:
		"_cima":
			spawn_position = muzzle_cima.global_position
		"_baixo":
			spawn_position = muzzle_baixo.global_position
			
		"_direita":
			# --- ESTA É A CORREÇÃO ---
			# Verifica se o sprite está virado para a esquerda
			if sprite_animado.flip_h:
				# Se sim, pega a posição LOCAL do muzzle
				var local_pos = muzzle_direita.position
				# Inverte o X dela manualmente
				local_pos.x *= -1
				# Converte essa nova posição local para a posição global
				spawn_position = sprite_animado.to_global(local_pos)
			else:
				# Se não, (olhando para a direita), usa a posição global normal
				spawn_position = muzzle_direita.global_position
			# -------------------------
			
		_:
			# Caso de segurança
			spawn_position = muzzle_direita.global_position

	# Define a posição da bala para o ponto de spawn calculado
	bullet.global_position = spawn_position
	
	# O resto do seu código
	bullet.direction = direction
	bullet.cor_arma = estado_arma 
	
	get_tree().current_scene.add_child(bullet)

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func _on_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.
