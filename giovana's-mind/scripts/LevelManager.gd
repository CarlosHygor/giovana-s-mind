extends Node

const NUM_ROOMS = 10
const FINAL_FLOOR = 1 
var current_floor = 1

var floor_1_scenes = {
	RoomType.START : preload("res://cenas/Room.tscn"),
	RoomType.NORMAL: [
		preload("res://cenas/roomTeste.tscn"),
		preload("res://cenas/room_1.tscn")
	],
	RoomType.TREASURE : preload("res://cenas/tesouro.tscn"),
	RoomType.BOSS: preload("res://cenas/boss_room.tscn")
}

var floor_2_scenes = {
	RoomType.START : preload("res://cenas/Room.tscn"),
	RoomType.NORMAL: [
		preload("res://cenas/roomTeste.tscn"),
		preload("res://cenas/room_1.tscn")
	],
	RoomType.TREASURE : preload("res://cenas/tesouro.tscn"),
	RoomType.BOSS: preload("res://cenas/boss_room.tscn")
}



var current_room_scene_map = {}
var map_grid = {}
var current_room_coord = Vector2i.ZERO
var current_room_node: Node2D = null

enum RoomType {START, NORMAL, BOSS, TREASURE, SHOP}

class RoomData:
	var type : RoomType = RoomType.NORMAL
	var is_cleared : bool = false

func _ready():
	pass

func generate_floor():
	map_grid.clear()
	var walker_pos = Vector2i.ZERO
	
	var start_room_data = RoomData.new()
	start_room_data.type = RoomType.START
	start_room_data.is_cleared = true
	map_grid[walker_pos] = start_room_data
	
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	
	for i in range(NUM_ROOMS):
		var new_dir = directions.pick_random()
		walker_pos += new_dir
		while map_grid.has(walker_pos):
			walker_pos += directions.pick_random()
		var new_room_data = RoomData.new()
		new_room_data.type = RoomType.NORMAL
		map_grid[walker_pos] = new_room_data
	
	var boss_room_data = map_grid[walker_pos]
	boss_room_data.type = RoomType.BOSS
	
	print("Mapa gerado:", map_grid)

func start_floor():
	current_room_scene_map = floor_1_scenes
	generate_floor()
	current_room_coord = Vector2i.ZERO
	load_room(current_room_coord)

func load_room(coord: Vector2i):
	if current_room_node != null:
		current_room_node.queue_free()
	
	var room_data = map_grid.get(coord, RoomData.new())
	var room_type = room_data.type
	
	var scene_to_load
	var scene_data = current_room_scene_map.get(room_type, null)
	
	if scene_data == null:
		print("Aviso: Tipo de sala %s não encontrado. Usando NORMAL." % RoomType.keys()[room_type])
		scene_data = current_room_scene_map[RoomType.NORMAL]
		
	if scene_data is Array:
		scene_to_load = scene_data.pick_random()
	else:
		scene_to_load = scene_data

	current_room_node = scene_to_load.instantiate()
	current_room_node.set_cleared_state(room_data.is_cleared)
	
	var neighbors = {
		"north": map_grid.has(coord + Vector2i.UP),
		"south": map_grid.has(coord + Vector2i.DOWN),
		"east": map_grid.has(coord + Vector2i.RIGHT),
		"west": map_grid.has(coord + Vector2i.LEFT)
	}
	
	current_room_node.setup_doors(neighbors)
	current_room_node.player_entered_door.connect(_on_player_entered_door)
	current_room_node.room_cleared.connect(_on_room_cleared)
	
	get_tree().current_scene.get_node("RoomHolder").add_child(current_room_node)

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

func _on_room_cleared():
	if map_grid.has(current_room_coord):
		var room_data = map_grid[current_room_coord]
		room_data.is_cleared = true
		print("LevelManager guardou o estado 'limpo' para ", current_room_coord)

func go_to_next_floor():
	if current_floor == FINAL_FLOOR:
		print("Agora vai")
		get_tree().change_scene_to_file("res://cenas/end_cutscene.tscn")
		return
	
	current_floor += 1
	
	match current_floor:
		1:
			current_room_scene_map = floor_1_scenes
		2:
			current_room_scene_map = floor_2_scenes
		_:
			current_room_scene_map = floor_2_scenes 

	generate_floor()
	current_room_coord = Vector2i.ZERO
	load_room(current_room_coord)
	
	var player = get_tree().get_first_node_in_group("player")
	if player and current_room_node:
		var spawn_marker = current_room_node.get_node("SpawnPoint_South")
		player.global_position = spawn_marker.global_position
		
func get_opposite_direction_name(dir: Vector2i):
	if dir == Vector2i.UP:
		return "South"
	if dir == Vector2i.DOWN:
		return "North"
	if dir == Vector2i.LEFT:
		return "East"
	if dir == Vector2i.RIGHT:
		return "West"
	return "South"
