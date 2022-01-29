extends Node2D

const PlayerState = preload("./PlayerState.gd")

export var size = 32
export var speed = 50
export var current_cell = Vector2() setget set_current_cell
export var available_directions = {
	'up': false,
	'down': false,
	'left': false,
	'right': false
}

var cell_center = Vector2()
var cell_pos = Vector2()
var velocity = Vector2()
var player_size = 10
signal move(player_position)

onready var playerState = PlayerState.new();

func set_init_position(pos):
	position = pos
	print(get_global_position())
	emit_signal("move", get_global_position())

func get_input():
	var ui_pressed = false
	
	var x = floor(position.x)
	var y = floor(position.y)
	var x_diff = abs(cell_center.x - x)
	var y_diff = abs(cell_center.y - y)
	
	if Input.is_action_just_pressed('ui_right') && Input.is_action_pressed('ui_right'):
		playerState.handleDirectionPressed(PlayerState.DIRECTION.RIGHT);
	elif Input.is_action_just_pressed('ui_left') && Input.is_action_pressed('ui_left'):
		playerState.handleDirectionPressed(PlayerState.DIRECTION.LEFT);
	elif Input.is_action_just_pressed('ui_up') && Input.is_action_pressed('ui_up'):
		playerState.handleDirectionPressed(PlayerState.DIRECTION.UP);
	elif Input.is_action_just_pressed('ui_down') && Input.is_action_pressed('ui_down'):
		playerState.handleDirectionPressed(PlayerState.DIRECTION.DOWN);
	
	velocity = Vector2()
	if Input.is_action_pressed('ui_right') && position.y == cell_center.y:
		ui_pressed = true
		velocity.x += 1
	if Input.is_action_pressed('ui_left') && position.y == cell_center.y:
		ui_pressed = true
		velocity.x -= 1
	if Input.is_action_pressed('ui_up') && position.x == cell_center.x:
		ui_pressed = true
		velocity.y -= 1
	if Input.is_action_pressed('ui_down') && position.x == cell_center.x:
		ui_pressed = true
		velocity.y += 1
	
	if ui_pressed:
		velocity = velocity.normalized() * speed
		emit_signal("move", get_global_position())

func set_current_cell(cell):
	current_cell = cell
	var half_size = (size / 2)
	cell_pos = (cell * size)
	cell_center = (cell * size) + Vector2(half_size, half_size)

func _process(delta):
	get_input()
	position += velocity * delta
	
	if available_directions.up == false:
		position.y = clamp(position.y, cell_center.y, cell_center.y + (size / 2))
	if available_directions.down == false:
		position.y = clamp(position.y, cell_center.y - (size / 2) - 1, cell_center.y)
	if available_directions.left == false:
		position.x = clamp(position.x, cell_center.x, cell_center.x + (size / 2))
	if available_directions.right == false:
		position.x = clamp(position.x, cell_center.x - (size / 2) - 1, cell_center.x)
