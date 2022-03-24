extends Node2D

const PlayerState = preload("./PlayerState.gd")

onready var screen_dimensions = get_viewport().size 

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
var last_ping_position = Vector2()

signal move(player_position)
signal drop_ping(ping_position)

onready var playerState = PlayerState.new();

func _ready():
	emit_signal("move", get_global_position())
	set_ping()

func get_input():
	var ui_pressed = false
	
	if Input.is_action_just_pressed('ui_right') && Input.is_action_pressed('ui_right'):
		playerState.handleDirectionPressed(PlayerState.DIRECTION.RIGHT);
	elif Input.is_action_just_pressed('ui_left') && Input.is_action_pressed('ui_left'):
		playerState.handleDirectionPressed(PlayerState.DIRECTION.LEFT);
	elif Input.is_action_just_pressed('ui_up') && Input.is_action_pressed('ui_up'):
		playerState.handleDirectionPressed(PlayerState.DIRECTION.UP);
	elif Input.is_action_just_pressed('ui_down') && Input.is_action_pressed('ui_down'):
		playerState.handleDirectionPressed(PlayerState.DIRECTION.DOWN);
	
	velocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		ui_pressed = true
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		ui_pressed = true
		velocity.x -= 1
	if Input.is_action_pressed('ui_up'):
		ui_pressed = true
		velocity.y -= 1
	if Input.is_action_pressed('ui_down'):
		ui_pressed = true
		velocity.y += 1
	
	playerState.isMoving(ui_pressed)

	if playerState.isMoving():
		velocity = velocity.normalized() * speed
		emit_signal("move", get_global_position())
	else:
		set_ping()

func set_ping():
	last_ping_position = get_global_position()

func get_ping():
	return last_ping_position

func set_current_cell(cell):
	current_cell = cell
	var half_size = (size / 2)
	cell_pos = (cell * size)
	cell_center = (cell * size) + Vector2(half_size, half_size)

func _physics_process(delta):
	get_input()
	position += velocity * delta

	if get_ping().distance_to(position) >= 20:
		emit_signal("drop_ping", get_global_position())
		set_ping()
	
#	if available_directions.up == false:
#		position.y = clamp(position.y, cell_center.y, cell_pos.y + size)
#	if available_directions.down == false:
#		position.y = clamp(position.y, cell_pos.y + size, cell_center.y)
