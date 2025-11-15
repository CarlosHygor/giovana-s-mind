extends CharacterBody2D

@export var move_speed: float = 200.0
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.4

var can_shoot := true

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

	# ---------- TIRO ----------
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
	
	get_tree().current_scene.add_child(bullet)

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
