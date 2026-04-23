extends Node

## The size of one tilemap cell (in pixels)
const CELL_SIZE: int = 128
## The name of the group where interactables are added
const INTERACTABLE_GROUP: String = "Interactable"

#region Spiders
## How fast the spiders move
const ENEMY_SPEED: int = 3.5 * CELL_SIZE
## How much health the player loses when hit by a spider
const ENEMY_DAMAGE_DONE: int = 10
## The minimum amount of spiders that can spawn when an egg is triggered
const ENEMIES_TO_SPAWN_MIN : int = 15
## The maximum amount of spiders that can spawn when an egg is triggered
const ENEMIES_TO_SPAWN_MAX : int = 25
## The delay between each spider spawn when an egg is spawning
const TIME_BETWEEN_ENEMY_SPAWNS : float = 0.15

## How many times eggs have to be scanned before a swarm is triggered
const SCANS_BEFORE_SWARM: int = 4
## How much money it costs to destroy an egg
const EGG_DESTROY_COST: int = 10
#endregion

#region Upgrades
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
## Stores every possible upgrade
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
## Maps every possible upgrade to 1 if owned and 0 if not owned (initialized on ready)
var _current_upgrades: Dictionary = {}
#endregion

#region Tile Bonuses
## Probability of spawning anything
const TILE_SPAWN_RATIO = 0.4
## The minimum base amount of money gained from a tile
const MIN_BASE_MONEY_GAIN: int = 25
## The maximum base amount of money gained from a tile
const MAX_BASE_MONEY_GAIN: int = 50
## Dictionary holding all the possible spawnable tile types and their weights
const TILE_TYPE_WEIGHTS: Dictionary[TileType,float] = {
	TileType.MONEY: 0.8,
	TileType.HEALTH: 0.2,
	TileType.FUEL: 1.2,
	TileType.EGG: 1.5
}
## Stores every type of bonus in a tile
enum TileType {
	NONE,
	MONEY,
	HEALTH,
	FUEL,
	EGG,
}
#endregion

## How much stamina one scan costs
const SCAN_COST: int = 2
## How much time the player has to wait before scanning again (min 1.0)
const SCAN_COOLDOWN: float = 1.0

#region Game scenes
var main_menu_scene: PackedScene = load("uid://b67yrqq2iad43")
var end_menu_scene: PackedScene = load("uid://babguvhbhaser")
var level_scene: PackedScene = load("uid://btoglak145h8n")
#endregion

#region Scene object references
## Reference to the world map tiles scene
var world_map_tiles_ref: WorldMapTiles
## Reference to the enemy holder scene
var enemy_holder_ref: Node2D
## Reference to the player scene
var player_ref: Player
## Reference to the HUD scene
var hud_ref: Hud
#endregion

## The current amount of money the player has
var _currency := 0
## The current maximum health amount the player can have
var max_health := 100
## The current maximum stamina amount the player can have
var max_fuel := 10

## Stores a random number generator
var rng: RandomNumberGenerator

var end_state := false

func _ready() -> void:
	randomize()
	rng = RandomNumberGenerator.new()
	
	for upgrade in Upgrades.values():
		_current_upgrades[upgrade] = 0

func set_currency(delta: int):
	_currency = _currency + delta
	Signals.currency_changed.emit(_currency)
	hud_ref.update_currency_label(_currency)

func get_currency() -> int:
	return _currency

## Returns the base amount of resource to gain when digging resources
func get_base_resource_gain(resource_id: int) -> float:
	match resource_id:
		TileType.HEALTH:
			return ENEMY_DAMAGE_DONE * 2
		TileType.FUEL:
			return float(SCAN_COST) / 2.0
		TileType.MONEY:
			return randf_range(MIN_BASE_MONEY_GAIN, MAX_BASE_MONEY_GAIN)
	return 0

func get_cost_from_tier(tier) -> int:
	var cost = 500
	match tier:
		1:
			cost = 20
		2:
			cost = 200
		3:
			cost = 500
	return cost

func add_upgrade(upgrade_type: Upgrades):
	_current_upgrades[upgrade_type] = 1;
	hud_ref.add_upgrade(upgrade_type)
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
		
func deferred_change_scene(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed.call_deferred(scene)
