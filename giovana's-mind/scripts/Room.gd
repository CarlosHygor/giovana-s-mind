extends Node2D

var is_cleared = false
var enemy_count = 0

signal player_entered_door(direction)
signal room_cleared

@onready var enemies_node = $Enemies

func _ready() -> void:
	if is_cleared:
		enemy_count = 0
		for enemy in enemies_node.get_children():
			enemy.queue_free()
	else:
		enemy_count = enemies_node.get_child_count()
		if enemy_count > 0:
			lock_all_doors()
		else:
			is_cleared = true
			unlock_all_doors()

func set_cleared_state(cleared_status:bool):
	self.is_cleared = cleared_status

func setup_doors(neighbors: Dictionary):
	if neighbors.north:
		$Doors/DoorNorth.open_door()
	else:
		$Doors/DoorNorth.hide_door()
	
	if neighbors.south:
		$Doors/DoorSouth.open_door()
	else:
		$Doors/DoorSouth.hide_door()
	
	if  neighbors.east:
		$Doors/DoorEast.open_door()
	else:
		$Doors/DoorEast.hide_door()
	
	if neighbors.west:
		$Doors/DoorWest.open_door()
	else:
		$Doors/DoorWest.hide_door()

func lock_all_doors():
	for Door in $Doors.get_children():
		if Door.is_visible:
			Door.close_door()

func unlock_all_doors():
	for Door in $Doors.get_children():
		Door.open_door()

func _on_door_north_player_triggered() -> void:
	player_entered_door.emit(Vector2i.UP)

func _on_door_south_player_triggered() -> void:
	player_entered_door.emit(Vector2i.DOWN)

func _on_door_east_player_triggered() -> void:
	player_entered_door.emit(Vector2i.RIGHT)

func _on_door_west_player_triggered() -> void:
	player_entered_door.emit(Vector2i.LEFT)

func _on_enemies_child_exiting_tree(node: Node) -> void:
	enemy_count -= 1
	if enemy_count <= 0:
		print("sala limpa")
		unlock_all_doors()
		is_cleared = true
		room_cleared.emit
