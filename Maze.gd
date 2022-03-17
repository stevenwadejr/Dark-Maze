extends Node2D

const N = 1
const E = 2
const S = 4
const W = 8

const GRID_SIZE = 32

const LightTexture = preload("res://assets/Light.png")

var cell_walls = {
	Vector2(0, -1): N,
	Vector2(1, 0): E,
	Vector2(0, 1): S,
	Vector2(-1, 0): W
}

var border_width = 1
var tile_size = Vector2(GRID_SIZE, GRID_SIZE)
var width = 26
var height = 24

onready var Map = $MazeGrid
onready var Player = $Player
onready var Potato = $Potato
onready var Fog = $Fog
onready var ColorMask = $ColorMask
onready var Camera = $Player/PlayerCamera

var maze_width = width * GRID_SIZE
var maze_height = height * GRID_SIZE

var colorMaskImage = Image.new()
var colorMaskTexture = ImageTexture.new()

var fogImage = Image.new()
var fogTexture = ImageTexture.new()
var lightImage = LightTexture.get_data()
var light_offset = Vector2(GRID_SIZE * 3 / 2, GRID_SIZE * 3 / 2)

func _ready():
	randomize()
	tile_size = Map.cell_size
	generate_maze()
	position_player()
	position_potato()
	overlay_color()
	generate_fog()
	update_fog(Player.position)
	Player.connect('move', self, '_on_player_move')

func generate_fog():
	fogImage.create(maze_width, maze_height, false, Image.FORMAT_RGBAH)
	fogImage.fill(Color.black)
	lightImage.convert(Image.FORMAT_RGBAH)
	lightImage.resize(GRID_SIZE * 3, GRID_SIZE * 3)

func update_fog(new_grid_position):
	fogImage.lock()
	lightImage.lock()
	
	var light_rect = Rect2(Vector2.ZERO, Vector2(lightImage.get_width(), lightImage.get_height()))
	fogImage.blend_rect(lightImage, light_rect, new_grid_position - light_offset)
	
	fogImage.unlock()
	lightImage.unlock()
	
	update_fog_image_texture()

func update_fog_image_texture():
	fogTexture.create_from_image(fogImage)
	Fog.texture = fogTexture

func _on_player_move(player_position):
	var pos = Map.world_to_map(player_position)
	Player.current_cell = pos
	var cell_name = Map.tile_set.tile_get_name(get_player_cell(pos))
	var cell_walls = int(cell_name)
	Player.available_directions = {
		'up': (N & cell_walls) == 0,
		'down': (S & cell_walls) == 0,
		'left': (W & cell_walls) == 0,
		'right': (E & cell_walls) == 0
	}
	
	update_fog(player_position)

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

func position_potato():
	Potato.position = Map.map_to_world(get_random_map_tile()) + tile_size / 2

func get_random_map_tile():
	var used_cells = Map.get_used_cells()
	return used_cells[randi() % used_cells.size()]

func get_player_cell(player_position: Vector2):
	return Map.get_cellv(player_position)

func overlay_color():
	colorMaskImage.create(maze_width, maze_height, false, Image.FORMAT_RGBAH)
	colorMaskImage.fill(Color(0.0, 1.0, 0.4, 0.8))
	colorMaskTexture.create_from_image(colorMaskImage)
	ColorMask.texture = colorMaskTexture
	ColorMask.scale *= GRID_SIZE
