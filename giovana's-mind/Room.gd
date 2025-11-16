extends Node2D

signal player_entered_door(direction)

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
