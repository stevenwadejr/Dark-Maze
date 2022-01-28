extends Node

export var pressed = [];

const UP = 'up';
const DOWN = 'down';
const LEFT = 'left';
const RIGHT = 'right';

enum DIRECTION {
	UP,
	DOWN,
	LEFT,
	RIGHT
};

var nextDirection;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func handleDirectionPressed(dir):
	assert(dir in DIRECTION.values())
	nextDirection = dir;

func getNextDirection():
	return nextDirection;
