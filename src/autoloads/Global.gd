extends Node

@export var PLAYER_SPEED = 3000
#@export var ENEMY_SPEED = 6000
@export var ENEMY_SPEED = 20000

@export var PLAYER_HEALTH = 100 
@export var ENEMY_DAMAGE_DONE = 10 

# not yet used
@export var ENEMIES_TO_SPAWN_MAX : int = 15
@export var ENEMIES_TO_SPAWN_MIN : int = 6

# used
@export var ENEMIES_TO_SPAWN : int = 10
@export var TIME_BETWEEN_ENEMY_SPAWNS : float = 0.2

const CELL_SIZE = 128
const  MAX_MINING_STRENGTH: int = 4

var rng: RandomNumberGenerator
var max_health := 10
var max_fuel := 10

var _currency := 12
var _current_upgrades = {}

enum Upgrades {
	HEALTH_1,
	HEALTH_2,
	HEALTH_3,
	FUEL_1,
	FUEL_2,
	FUEL_3,
	DRILL_1,
	DRILL_2,
	DRILL_3,
	SCANNER_1,
	SCANNER_2,
	SCANNER_3,
}

# Reference to the world map tiles scene
var world_map_tiles: WorldMapTiles

# Reference to the player scene
var player_ref: Player


func _ready() -> void:
	randomize()
	rng = RandomNumberGenerator.new()

	for upgrade in Upgrades.values():
		_current_upgrades[upgrade] = 0


func set_currency(delta: int):
	_currency = max(_currency + delta, 0)
	Signals.currency_changed.emit(_currency)


func get_currency() -> int:
	return _currency


func add_upgrade(upgrade_type):
	_current_upgrades[upgrade_type] = 1;
	
