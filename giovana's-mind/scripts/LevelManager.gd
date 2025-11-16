extends Node

const NUM_ROOMS = 10

var room_scene_map ={
	RoomType.START : preload("res://cenas/room.tscn"),
	RoomType.NORMAL: preload("res://cenas/roomTeste.tscn")
}
var map_grid = {}
var current_room_coord = Vector2i.ZERO
var current_room_node: Node2D = null

enum  RoomType {START,NORMAL,BOSS,TRESAURE,SHOP}

func generate_floor():
	map_grid.clear()
	var walker_pos = Vector2i.ZERO
	
	map_grid[walker_pos] = RoomType.START
	var directions = [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]
	

	for i in range(NUM_ROOMS):
		var new_dir = directions.pick_random()
		walker_pos += new_dir
		while map_grid.has(walker_pos):
			walker_pos += directions.pick_random()
		map_grid[walker_pos] = RoomType.NORMAL
	
	map_grid[walker_pos] = RoomType.BOSS
	print("Mapa gerado:",map_grid)

func start_floor():
	generate_floor()
	current_room_coord = Vector2i.ZERO
	load_room(current_room_coord)

func load_room(coord:Vector2i):
	if current_room_node != null:
		current_room_node.queue_free()
	
	var room_type = map_grid.get(coord ,RoomType.NORMAL)
	var scene_to_load = room_scene_map.get(room_type, room_scene_map[RoomType.NORMAL])
	
	current_room_node =scene_to_load.instantiate()
	
	var neighbors = {
		"north": map_grid.has(coord + Vector2i.UP),
		"south": map_grid.has(coord + Vector2i.DOWN),
		"east": map_grid.has(coord + Vector2i.RIGHT),
		"west": map_grid.has(coord + Vector2i.LEFT)
	}
	
	current_room_node.setup_doors(neighbors)
	current_room_node.player_entered_door.connect(_on_player_entered_door)
	get_tree().current_scene.add_child(current_room_node)

func _on_player_entered_door(direction: Vector2i):
	var new_coord = current_room_coord + direction
	if not map_grid.has(new_coord):
		print("sala inexistente")
		return
	current_room_coord = new_coord
	load_room(current_room_coord)
	
	var player = get_tree().get_first_node_in_group("player")
	var spawn_marker_name = "SpawnPoint_" + get_opposite_direction_name(direction)
	var spawn_marker = current_room_node.get_node(spawn_marker_name)
	
	player.global_position = spawn_marker.global_position


func get_opposite_direction_name(dir: Vector2i):
	if dir == Vector2i.UP:
		return "South"
	if dir == Vector2i.DOWN:
		return "North"
	if dir == Vector2i.LEFT:
		return "East"
	if dir == Vector2i.RIGHT:
		return "South"
