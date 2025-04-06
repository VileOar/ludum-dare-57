extends Node

@export var PLAYER_SPEED = 3000
@export var ENEMY_SPEED = 6000

@export var PLAYER_HEALTH = 100 
@export var ENEMY_DAMAGE_DONE = 10 

# not yet used
@export var ENEMIES_TO_SPAWN_MAX : int = 15
@export var ENEMIES_TO_SPAWN_MIN : int = 6

# used
@export var ENEMIES_TO_SPAWN : int = 10
@export var TIME_BETWEEN_ENEMY_SPAWNS : float = 0.2

const CELL_SIZE = 128

var rng: RandomNumberGenerator


func _ready() -> void:
	randomize()
	rng = RandomNumberGenerator.new()
