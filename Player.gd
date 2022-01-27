extends Node2D

export var size = 32
export var speed = 50
export var current_cell = Vector2() setget set_current_cell
var cell_center = Vector2()
var velocity = Vector2()
signal move(player_position)

func _ready():
	emit_signal("move", get_global_position())

func get_input():
	var ui_pressed = false
	
#	if abs(cell_center.y - floor(position.y)) == 1:
#		print("reset Y ")
#		position.y = cell_center.y
#
#	if abs(cell_center.x - floor(position.x)) == 1:
#		print("reset X ")
#		position.x = cell_center.x
	
	var x = floor(position.x)
	var y = floor(position.y)
	var x_diff = abs(cell_center.x - x)
	var y_diff = abs(cell_center.y - y)
	
	velocity = Vector2()
	if Input.is_action_pressed('ui_right') and y_diff == 0:
		ui_pressed = true
		velocity.x += 1
		velocity.y = 0
	if Input.is_action_pressed('ui_left') and y_diff == 0:
		ui_pressed = true
		velocity.x -= 1
		velocity.y = 0
	if Input.is_action_pressed('ui_up') and x_diff == 0:
		ui_pressed = true
		velocity.y -= 1
		velocity.x = 0
	if Input.is_action_pressed('ui_down') and x_diff == 0:
		ui_pressed = true
		velocity.y += 1
		velocity.x = 0
	
	print(Vector2(x, y), cell_center)
	
	if ui_pressed:
		velocity = velocity.normalized() * speed
		emit_signal("move", get_global_position())

func set_current_cell(cell):
	current_cell = cell
	var half_size = (size / 2)
	cell_center = (cell * size) + Vector2(half_size, half_size)
#	print("Set current cell ", cell_center)

func _physics_process(delta):
	get_input()
	position += velocity * delta
