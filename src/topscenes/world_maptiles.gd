class_name WorldMapTiles
extends Node2D

# TODO: remove
var strength = 0

## The rectangle encompassing the full traverseable map
const MAP_LIMITS := Rect2i(-25, -25, 50, 100)
const TOTAL_TILE_AMOUNT: int = MAP_LIMITS.size.x * MAP_LIMITS.size.y

# TODO: change
## The y value above which danger should effectively be 0
const MIN_DANGER_Y = -25
## The y value below which danger should effectively be 1
const MAX_DANGER_Y = 75
## the max value to add/subtract to the danger value, depending on y coordinate
const MAX_DANGER_MODIFIER = 0.5

## The hue to be used for the danger indication
const BASE_DANGER_HUE := 0.74
## The minimum colour brightness, relative to danger tiles
const MIN_COLOR_BRI := 0.2

@onready var _egg_spawner: Node2D = %EggSpawner
@onready var _tiles: MapTiles = $MapTiles
@onready var _danger_levels: TileMapLayer = $DangerLevels
@onready var _nav_layer: TileMapLayer = $NavLayer

# Dictionary holding the thresholds under which different terrains should spawn.[br]
var _terrain_noise_thresholds := {
	0.3: 0,
	0.6: 1,
	0.8: 2,
	1.0: 3
}

var load_percent: int = 0
var thread: Thread
var are_tiles_generated: bool = false

func _ready() -> void:
	thread = Thread.new()
	thread.start(_generate_tiles, 2)
	Global.world_map_tiles = self


## Attempt to dig a tile at a position.
func try_dig_tile(pos: Vector2, dig_strength: int) -> bool:
	var cell_pos = _tiles.local_to_map(pos)
	if _tiles.get_cell_tile_data(cell_pos) == null:
		return false
	
	var can_dig = _can_dig(cell_pos, dig_strength)

	if can_dig:
		_dig_tiles([cell_pos])
	else:
		AudioController.play_stone_dig_fail()
	
	return can_dig


# Whether the cell at the given position can be dug with given strentgh
func _can_dig(cell_pos: Vector2i, dig_strength: int) -> bool:
	var tile_data = _tiles.get_cell_tile_data(cell_pos)
	if tile_data == null:
		return false
	var hardness = tile_data.get_custom_data("hardness")
	return dig_strength >= hardness


# Method to execute a dig action on group of tile, which removes the tiles and updates necessary data.
func _dig_tiles(cells: Array[Vector2i]):
	for cell in cells:
		_danger_levels.set_cell(cell, 0, Vector2i(-1, -1))
		var cell_data = _tiles.get_cell_tile_data(cell)
		if cell_data != null:
			var hardness = cell_data.get_custom_data("hardness")
			if hardness == 0:
				AudioController.play_dirt_dig()
			else:
				AudioController.play_stone_dig()
#			TODO tmp
			_egg_spawner.instantiate_egg(cell * Global.CELL_SIZE + Vector2i.ONE * (Global.CELL_SIZE / 2))
	_set_cells(cells, -1)

	#_tiles.force_update_tiles()


# Internal method to set cells to the terrain tilemap layer
func _set_cells(cells: Array[Vector2i], terrain):
	_tiles.set_cells_terrain_connect(cells, 0, terrain)
	if terrain == -1:
		_nav_layer.set_cells_terrain_connect(cells, 0, 0)
	else:
		_nav_layer.set_cells_terrain_connect(cells, 0, -1)


func _generate_tiles():
	var map_seed = randi() # the main seed used to generate everything else
	Global.rng.seed = map_seed
	var danger_seed = Global.rng.randi() # get a different seed for a different noise map
	
	# the noise map for choosing the terrain of each tile
	var terrain_noise = _get_noise_map(map_seed, 0.02, _terrain_noise_thresholds.size(), 0.2)
	# the noise map for choosing the danger level (and spawning ratio) of enemy spawners
	var danger_noise = _get_noise_map(danger_seed, 0.01, 4, 0.0)
	
	var tile_num: int = 0
	
	# set the terrains according to noise
	for yy in range(MAP_LIMITS.position.y, MAP_LIMITS.end.y):
		for xx in range(MAP_LIMITS.position.x, MAP_LIMITS.end.x):
			var cell = Vector2i(xx, yy)
			
			var terrain = _noise_to_terrain(terrain_noise.get_noise_2dv(cell))
			_set_cells([cell], terrain)
			
			var danger_level = (danger_noise.get_noise_2dv(cell) + 1.0)/2.0
			# adapt it to be above the minimum brightness value and calculate saturation
			danger_level = clamp(_get_danger_level(danger_level, yy), 0.0, 1.0)
			
			var shade_tile := _get_danger_tile(danger_level)
			_danger_levels.set_cell(cell, 0, shade_tile)
			
			tile_num += 1
			load_percent = floor(float(tile_num)/float(TOTAL_TILE_AMOUNT) * 100)
			
			#_tiles.update_tile(cell, func(tile_data: TileData): tile_data.modulate = col)
			
			# the chance to spawn something on a tile will be higher with higher danger levels
			var spawn_chance = Global.TILE_SPAWN_RATIO * danger_level
			if Global.rng.randf() < spawn_chance: # this tile will spawn something
				_spawn_tile_data(cell)
	#_tiles.force_update_tiles()
	are_tiles_generated = true


func _spawn_tile_data(cell_pos: Vector2i):
	var types = Global.tile_type_weights.keys()
	var selected = Global.rng.rand_weighted(Global.tile_type_weights.values())
	_tiles.save_cell_data(cell_pos, selected)


func _get_noise_map(noise_seed: float, frequency: float, fractal_octaves: int, fractal_gain: float) -> FastNoiseLite:
	var simplex_noise = FastNoiseLite.new()
	
	simplex_noise.seed = noise_seed
	
	simplex_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	simplex_noise.frequency = frequency
	simplex_noise.fractal_octaves = fractal_octaves
	simplex_noise.fractal_gain = fractal_octaves
	
	return simplex_noise


# || --- Conversions --- ||

# Get the appropriate terrain id based on the given noise value.[br]
# Returns the first terrain, where the asrgument is lower than the respective key
func _noise_to_terrain(noise_value: float) -> int:
	var fallback = -1
	for key in _terrain_noise_thresholds:
		fallback = _terrain_noise_thresholds[key]
		if noise_value <= key:
			return fallback
	return fallback


func _get_danger_tile(danger_ratio: float) -> Vector2i:
	var danger_step = 0.2
	danger_ratio = snapped(danger_ratio, danger_step)
	return Vector2i(int(danger_ratio / danger_step), 0)


# Calculate a danger value from the descending danger rule and a noise value (0 - 1)[br]
# Also depends on the cell y coordinate
func _get_danger_level(noise_value: float, cy: int) -> float:
	# get the percent of the y coordinate between the two limits
	var y_percent: float = float(cy - MIN_DANGER_Y) / float(MAX_DANGER_Y - MIN_DANGER_Y)
	# calculate the modifier
	var modifier = lerp(MAX_DANGER_MODIFIER, -MAX_DANGER_MODIFIER, y_percent)
	
	return noise_value - modifier
