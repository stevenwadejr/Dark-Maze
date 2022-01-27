extends Node2D

const N = 1
const E = 2
const S = 4
const W = 8

var cell_walls = {
	Vector2(0, -1): N,
	Vector2(1, 0): E,
	Vector2(0, 1): S,
	Vector2(-1, 0): W
}

var border_width = 1
var tile_size = Vector2(32, 32)
var width = 26
var height = 24

onready var Map = $MazeGrid
onready var Player = $Player

func _ready():
	randomize()
	tile_size = Map.cell_size
	generate_maze()
	position_player()
	Player.connect('move', self, '_on_player_move')

func _on_player_move(player_position):
	var pos = Map.world_to_map(player_position)
	Player.current_cell = pos
#	var cell_name = Map.tile_set.tile_get_name(get_player_cell(pos))
#	Player.available_directions = directions[int(cell_name)]

func check_neighbors(cell, unvisited):
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list

func generate_maze():
	var unvisited = []  # array of unvisited tiles
	var stack = []
	# fill the map with solid tiles
	Map.clear()
	for x in range(width):
		for y in range(height):
			unvisited.append(Vector2(x, y))
			Map.set_cellv(Vector2(x, y), N|E|S|W)
	var current = Vector2(0, 0)
	unvisited.erase(current)
	# execute recursive backtracker algorithm
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			# remove walls from *both* cells
			var dir = next - current
			var current_walls = Map.get_cellv(current) - cell_walls[dir]
			var next_walls = Map.get_cellv(next) - cell_walls[-dir]
			Map.set_cellv(current, current_walls)
			Map.set_cellv(next, next_walls)
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()

func position_player():
	var init_player_pos = get_random_map_tile()
	Player.position = Map.map_to_world(init_player_pos) + tile_size / 2
	Player.current_cell = Map.world_to_map(Player.position)

func get_random_map_tile():
	var used_cells = Map.get_used_cells()
	return used_cells[randi() % used_cells.size()]

func get_player_cell(player_position: Vector2):
	return Map.get_cellv(player_position)
