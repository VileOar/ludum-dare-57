extends Node

@export var PLAYER_SPEED = 3000
@export var ENEMY_SPEED = 450
#@export var ENEMY_SPEED = 20000

@export var ENEMY_DAMAGE_DONE = 10

var max_health := 100
var max_fuel := 10


# used
@export var ENEMIES_TO_SPAWN_MAX : int = 25
@export var ENEMIES_TO_SPAWN_MIN : int = 15
@export var ENEMIES_TO_SPAWN : int = 20
@export var TIME_BETWEEN_ENEMY_SPAWNS : float = 0.15

const CELL_SIZE = 128
const MAX_MINING_STRENGTH: int = 3

# Upgrades
# Health
const HEALTH_UPGRADE_1: int = 150
const HEALTH_UPGRADE_2: int = 200
const HEALTH_UPGRADE_3: int = 300
# Stamina
const FUEL_UPGRADE_1: int = 15
const FUEL_UPGRADE_2: int = 20
const FUEL_UPGRADE_3: int = 30
# Claws
const DRILL_UPGRADE_1: int = 1
const DRILL_UPGRADE_2: int = 2
const DRILL_UPGRADE_3: int = 3
#Scanner
const SCANNER_UPGRADE_1: int = 2
const SCANNER_UPGRADE_2: int = 3
const SCANNER_UPGRADE_3: int = 4

const INTERACTABLE_GROUP: String = "Interactable"

var rng: RandomNumberGenerator

var _currency := 120
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

enum TileType {
	NONE,
	MONEY,
	HEALTH,
	FUEL,
	EGG,
}
## Dictionary holding all the possible spawnable tile types and their weights
var tile_type_weights := {
	TileType.MONEY: 0.8,
	TileType.HEALTH: 0.2,
	TileType.FUEL: 1.2,
	TileType.EGG: 1.5
}
## Probability of spawning anything
const TILE_SPAWN_RATIO = 0.4

# Reference to the world map tiles scene
var world_map_tiles: WorldMapTiles

# Reference to Enemy Holder
var enemy_holder: Node2D

# Reference to the player scene
var player_ref: Player
# Reference to the HUD scene
var hud_ref: Hud

func _ready() -> void:
	randomize()
	rng = RandomNumberGenerator.new()

	for upgrade in Upgrades.values():
		_current_upgrades[upgrade] = 0


func set_currency(delta: int):
	_currency = max(_currency + delta, 0)
	Signals.currency_changed.emit(_currency)
	hud_ref.update_currency_label(_currency)


func get_currency() -> int:
	return _currency


func add_upgrade(upgrade_type: Upgrades):
	_current_upgrades[upgrade_type] = 1;
	match  upgrade_type:
		Upgrades.HEALTH_1:
			max_health = HEALTH_UPGRADE_1
			player_ref.set_health_to_max()
		
		Upgrades.HEALTH_2:
			max_health = HEALTH_UPGRADE_2
			player_ref.set_health_to_max()
		
		Upgrades.HEALTH_3:
			max_health = HEALTH_UPGRADE_3
			player_ref.set_health_to_max()
		
		Upgrades.FUEL_1:
			max_fuel = FUEL_UPGRADE_1
			player_ref.set_fuel_to_max()
		
		Upgrades.FUEL_2:
			max_fuel = FUEL_UPGRADE_2
			player_ref.set_fuel_to_max()
		
		Upgrades.FUEL_3:
			max_fuel = FUEL_UPGRADE_3
			player_ref.set_fuel_to_max()
		
		Upgrades.DRILL_1:
			player_ref.set_mining_strength(DRILL_UPGRADE_1)
		
		Upgrades.DRILL_2:
			player_ref.set_mining_strength(DRILL_UPGRADE_2)
		
		Upgrades.DRILL_3:
			player_ref.set_mining_strength(DRILL_UPGRADE_3)
		
		Upgrades.SCANNER_1:
			player_ref.set_radar_level(SCANNER_UPGRADE_1)
		
		Upgrades.SCANNER_2:
			player_ref.set_radar_level(SCANNER_UPGRADE_2)
		
		Upgrades.SCANNER_3:
			player_ref.set_radar_level(SCANNER_UPGRADE_3)
		
