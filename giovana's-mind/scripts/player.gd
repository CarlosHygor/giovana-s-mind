extends CharacterBody2D

@export var move_speed: float = 200.0
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.4

var can_shoot := true

# --- ESTADO DA ANIMAÇÃO ---
@onready var sprite_animado: AnimatedSprite2D = $Body/SpriteAnimado
# Controla a cor da arma atual: "azul" ou "roxo"
var estado_arma: String = "azul"

# Guarda a última direção para a animação "parado"
var direcao_parado: String = "_baixo" # Começa olhando para baixo

# Guarda se o sprite estava espelhado (para "parado_esquerda")
var ultimo_flip_h: bool = false

# ❤️ VIDA FRACIONADA (¼ = 1 unidade)
var hearts: int = 3                # quantidade de corações
var max_health: int = hearts * 4   # 4 unidades = 1 coração
var current_health: int = max_health
var is_dead: bool = false


# ---------- VIDA ----------
func take_damage(amount: int = 1) -> void:
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
	
	# --- 1. LEITURA DE INPUT ---
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1

	# --- 2. LÓGICA DE ANIMAÇÃO ---
	var prefixo_movimento: String
	var sufixo_direcao: String
	
	if input_vector.length() > 0:
		# ----- ESTADO: ANDANDO -----
		prefixo_movimento = "andar"
		
		# Prioriza o movimento horizontal para animação
		if input_vector.x != 0:
			sufixo_direcao = "_direita"
			direcao_parado = "_direita" # Salva para quando parar
			
			# Vira o sprite para a esquerda
			sprite_animado.flip_h = (input_vector.x < 0) 
			
		elif input_vector.y < 0:
			sufixo_direcao = "_cima"
			direcao_parado = "_cima"
			sprite_animado.flip_h = false # Cima/Baixo não são espelhados
			
		elif input_vector.y > 0:
			sufixo_direcao = "_baixo"
			direcao_parado = "_baixo"
			sprite_animado.flip_h = false
			
		# Salva o último estado do flip
		ultimo_flip_h = sprite_animado.flip_h
		
	else:
		# ----- ESTADO: PARADO -----
		prefixo_movimento = "parada"
		sufixo_direcao = direcao_parado # Usa a última direção que estávamos
		
		# Se a última direção foi "direita", aplica o último flip
		if sufixo_direcao == "_direita":
			sprite_animado.flip_h = ultimo_flip_h
		else:
			sprite_animado.flip_h = false

	
	# --- 3. MONTAGEM DO NOME DA ANIMAÇÃO ---
	var anim_name: String
	
	# Caso especial: Cima não tem cor (baseado na sua lista)
	if sufixo_direcao == "_cima":
		anim_name = prefixo_movimento + sufixo_direcao
	else:
		# Montagem padrão: ex: "andar" + "_direita" + "_azul"
		anim_name = prefixo_movimento + sufixo_direcao + "_" + estado_arma
		
	# --- 4. TOCA A ANIMAÇÃO ---
	# Só toca a animação se ela for diferente da atual
	if sprite_animado.animation != anim_name:
		sprite_animado.play(anim_name)

	# --- 5. APLICA MOVIMENTO ---
	input_vector = input_vector.normalized()
	velocity = input_vector * move_speed
	move_and_slide()

	# --- 6. LÓGICA DE TIRO ---
	var shoot_dir = get_shoot_direction()
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
	bullet.global_position = global_position
	bullet.direction = direction
	
	# Passa a cor da arma atual para a variável "cor_arma" da bala
	bullet.cor_arma = estado_arma 
	
	get_tree().current_scene.add_child(bullet)

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true


func _on_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.
