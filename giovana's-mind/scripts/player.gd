extends CharacterBody2D

@export var move_speed: float = 200.0
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.15

var can_shoot := true

# VIDA
var max_hearts: int = 3
var current_hearts: int = max_hearts
var is_dead: bool = false


func take_damage() -> void:
	if is_dead:
		return

	current_hearts -= 1

	if current_hearts <= 0:
		current_hearts = 0
		die()


func heal() -> void:
	if is_dead:
		return

	current_hearts += 1

	if current_hearts > max_hearts:
		current_hearts = max_hearts


func die() -> void:
	is_dead = true
	print("Player morreu!")
	# Você pode adicionar animação, game over, etc.


func _physics_process(delta: float) -> void:
	# MOVIMENTO
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1

	input_vector = input_vector.normalized()
	velocity = input_vector * move_speed
	move_and_slide()

	# TIRO (SETAS — SEM ROTAÇÃO DO PLAYER)
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

	# 🔥 Bala nasce no centro do player
	bullet.global_position = global_position
	
	# Direção do tiro
	bullet.direction = direction
	
	get_tree().current_scene.add_child(bullet)

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
