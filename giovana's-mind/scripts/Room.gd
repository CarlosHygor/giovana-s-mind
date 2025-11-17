extends Node2D

var is_cleared = false
var enemy_count = 0

signal player_entered_door(direction)
signal room_cleared

@onready var enemies_node = $Enemies

func _ready() -> void:
	print("Sala Carregou")
	$BlockerNorth/CollisionShape2D.disabled = true
	$BlockerSouth/CollisionShape2D.disabled = true
	$BlockerEast/CollisionShape2D.disabled = true
	$BlockerWest/CollisionShape2D.disabled = true

	if is_cleared:
		enemy_count = 0
		print("DEBUG: Sala já estava limpa.")
		for enemy in enemies_node.get_children():
			enemy.queue_free()
		unlock_all_doors()
	else:
		enemy_count = enemies_node.get_child_count()
		print("DEBUG: Contagem de inimigos: ", enemy_count)
		if enemy_count > 0:
			print("DEBUG: A trancar portas!")
			lock_all_doors()
		else:
			is_cleared = true
			unlock_all_doors()

func set_cleared_state(cleared_status:bool):
	self.is_cleared = cleared_status

func setup_doors(neighbors: Dictionary):
	$Doors/DoorNorth.get_node("Sprite").visible = neighbors.north
	$Doors/DoorSouth.get_node("Sprite").visible = neighbors.south
	$Doors/DoorEast.get_node("Sprite").visible = neighbors.east
	$Doors/DoorWest.get_node("Sprite").visible = neighbors.west

func lock_all_doors():
	print("DEBUG: A trancar portas (MÉTODO BLOCKER).")
	$BlockerNorth/CollisionShape2D.disabled = false
	$BlockerSouth/CollisionShape2D.disabled = false
	$BlockerEast/CollisionShape2D.disabled = false
	$BlockerWest/CollisionShape2D.disabled = false
	
	for door in $Doors.get_children():
		if door is Area2D:
			door.get_node("TriggerCollision").disabled = true

func unlock_all_doors():
	print("DEBUG: A destrancar portas (MÉTODO BLOCKER).")
	$BlockerNorth/CollisionShape2D.disabled = true
	$BlockerSouth/CollisionShape2D.disabled = true
	$BlockerEast/CollisionShape2D.disabled = true
	$BlockerWest/CollisionShape2D.disabled = true
	
	for door in $Doors.get_children():
		if door is Area2D:
			door.get_node("TriggerCollision").disabled = false

func _on_door_north_player_triggered() -> void:
	player_entered_door.emit(Vector2i.UP)

func _on_door_south_player_triggered() -> void:
	player_entered_door.emit(Vector2i.DOWN)

func _on_door_east_player_triggered() -> void:
	player_entered_door.emit(Vector2i.RIGHT)

func _on_door_west_player_triggered() -> void:
	player_entered_door.emit(Vector2i.LEFT)

func _on_enemies_child_exiting_tree(node: Node) -> void:
	if is_cleared:
		return
		
	enemy_count -= 1
	if enemy_count <= 0:
		print("sala limpa")
		unlock_all_doors()
		is_cleared = true
		room_cleared.emit()
