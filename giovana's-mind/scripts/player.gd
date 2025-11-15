extends CharacterBody2D

@export var move_speed: float = 200.0
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.15
var can_shoot := true


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


	# TIRO (SETAS)
	var shoot_dir = get_shoot_direction()

	if shoot_dir != Vector2.ZERO:
		$Body.rotation = shoot_dir.angle() # ← ROTACIONA SOMENTE O BODY

		if can_shoot:
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
	bullet.position = $Body/Muzzle.global_position
	bullet.direction = direction
	
	get_tree().current_scene.add_child(bullet)

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
