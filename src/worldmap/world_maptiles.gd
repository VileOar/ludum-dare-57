class_name WorldMapTiles
extends Node2D

## How many tiles should the bedrock border be.
const BEDROCK_THICKNESS := 8

const MAX_NAVIGATION_Y := -5

## The rectangle encompassing the full traverseable map.
const MAP_LIMITS := Rect2i(-25, -20, 50, 100)
const TOTAL_TILE_AMOUNT: int = MAP_LIMITS.size.x * MAP_LIMITS.size.y
const STARTING_AREA := Rect2i(-3, -2, 6, 4)

const X_START: int = MAP_LIMITS.position.x - BEDROCK_THICKNESS
const X_END: int = MAP_LIMITS.end.x + BEDROCK_THICKNESS
const Y_START: int = MAP_LIMITS.position.y
const Y_END: int = MAP_LIMITS.end.y + BEDROCK_THICKNESS

## The y value above which danger should effectively be 0.
const MIN_DANGER_Y = -5
## The y value below which danger should effectively be 1.
const MAX_DANGER_Y = 95
## the max value to add/subtract to the danger value, depending on y coordinate.
const MAX_DANGER_MODIFIER = 0.5

## The upper-most y value, at which all blocks should effectively be the strongest stone.
const TOP_STONE_Y = -20
## The lower-most y value, at which terrain generation should no longer be modified to include stone.
const BOTTOM_STONE_Y = -5

@onready var _tiles: MapTiles = $MapTiles
@onready var _danger_level1: TileMapLayer = $DangerLevel1
@onready var _danger_level2: TileMapLayer = $DangerLevel2
@onready var _danger_level3: TileMapLayer = $DangerLevel3
@onready var _danger_level4: TileMapLayer = $DangerLevel4
@onready var _danger_level5: TileMapLayer = $DangerLevel5
@onready var _nav_layer: TileMapLayer = $NavLayer

@onready var _danger_levels: Dictionary[int, TileMapLayer] = {
	1: _danger_level1,
	2: _danger_level2,
	3: _danger_level3,
	4: _danger_level4,
	5: _danger_level5,
}

# Dictionary holding the thresholds under which different terrains should spawn.[br]
var _terrain_noise_thresholds := {
	0.3: 0,
	0.6: 1,
	0.8: 2,
	1.0: 3
}

var load_percent: int = 0
var are_tiles_generated: bool = false

func _ready() -> void:
	_generate_tiles()
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


func is_stable() -> bool:
	return are_tiles_generated


func get_random_spawn_position() -> Vector2:
	var valid_cells = _nav_layer.get_used_cells()
	var cell = valid_cells[Global.rng.randi() % valid_cells.size()]
	return _nav_layer.map_to_local(cell)


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
		# erase danger cells
		for i in _danger_levels:
			BetterTerrain.set_cell(_danger_levels[i], cell, -1)
			BetterTerrain.update_terrain_cell(_danger_levels[i], cell)

		var cell_data = _tiles.get_cell_tile_data(cell)
		if cell_data != null:
			var hardness = cell_data.get_custom_data("hardness")
			if hardness == 0:
				AudioController.play_dirt_dig()
			else:
				AudioController.play_stone_dig()
			# try to dig a feature tile on position
			_tiles.try_dig_feature(cell)
	_set_cells(cells, -1)

# Internal method to set cells to the terrain tilemap layer
func _set_cells(cells: Array[Vector2i], terrain):
	BetterTerrain.set_cells(_tiles, cells, terrain)
	# if cell is deleted update nearby cells
	if terrain == -1:
		BetterTerrain.update_terrain_cells(_tiles, cells)
	
	for cell in cells:
		if terrain == -1 and cell.y >= MAX_NAVIGATION_Y:
			_nav_layer.set_cell(cell, 0, Vector2i.ZERO)
		else:
			_nav_layer.set_cell(cell)

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
	# also sets the bedrock tiles
	for yy in range(Y_START, Y_END):
		for xx in range(X_START, X_END):
			var cell = Vector2i(xx, yy)
			
			# this means that it is bedrock, so no generation will occur, but filled with bedrock
			if !MAP_LIMITS.has_point(cell):
				_set_cells([cell], 4)
				continue
			
			# tiles in starting area are empty
			if STARTING_AREA.has_point(cell):
				_set_cells([cell], -1)
				continue
			
			var noise = terrain_noise.get_noise_2dv(cell)
			# modify the noise value to account for forcing stone in the upper layers
			if yy >= TOP_STONE_Y and yy < BOTTOM_STONE_Y:
				var y_weight: float = float(yy - TOP_STONE_Y) / float(BOTTOM_STONE_Y - TOP_STONE_Y)
				var mod = lerp(2.0, 0.0, y_weight)
				noise = clamp(noise + mod, -1.0, 1.0)
			# generate the terrain tiles, deciding between the different dirt/stone tiles
			var terrain = _noise_to_terrain(noise)
			if terrain > 4 or terrain < 0:
				print("Terrain: %s" % terrain)
			_set_cells([cell], terrain)
			
			# determine the danger level of each tile
			var danger_value = (danger_noise.get_noise_2dv(cell) + 1.0)/2.0
			# adapt it to be above the minimum brightness value and calculate saturation
			danger_value = clamp(_get_danger_value(danger_value, yy), 0.0, 1.0)
			
			var danger_level := _get_danger_level(danger_value)
			if danger_level > 0:
				for i in range(danger_level):
					var danger_tilemap: TileMapLayer = _danger_levels[i + 1]
					BetterTerrain.set_cell(danger_tilemap, cell, 0)
			
			tile_num += 1
			load_percent = floor(float(tile_num)/float(TOTAL_TILE_AMOUNT) * 100)
			
			# the chance to spawn something on a tile will be higher with higher danger levels
			var spawn_chance = Global.TILE_SPAWN_RATIO * danger_value
			if Global.rng.randf() < spawn_chance: # this tile will spawn something
				_spawn_tile_data(cell, danger_value)
	
	are_tiles_generated = true
	Signals.map_stable.emit.call_deferred()
	
	# update terrains once generation ends
	var game_area: Rect2i = Rect2i(X_START, Y_START, X_END - X_START, Y_END - Y_START)
	BetterTerrain.update_terrain_area(_tiles, game_area)
	for i in _danger_levels:
		BetterTerrain.update_terrain_area(_danger_levels[i], game_area)


func _spawn_tile_data(cell_pos: Vector2i, amount: float):
	var types = Global.tile_type_weights.keys()
	var selected = types[Global.rng.rand_weighted(Global.tile_type_weights.values())] 
	_tiles.save_feature(cell_pos, selected, amount)


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
# Returns the first terrain, where the argument is lower than the respective key
func _noise_to_terrain(noise_value: float) -> int:
	var fallback = -1
	for key in _terrain_noise_thresholds:
		fallback = _terrain_noise_thresholds[key]
		if noise_value <= key:
			return fallback
	return fallback

# Returns a danger level (0 - 5)
func _get_danger_level(danger_ratio: float) -> int:
	var danger_step = 0.2
	danger_ratio = snapped(danger_ratio, danger_step)
	return int(danger_ratio / danger_step)


# Calculate a danger value from the descending danger rule and a noise value (0 - 1)[br]
# Also depends on the cell y coordinate
func _get_danger_value(noise_value: float, cy: int) -> float:
	if cy <= MIN_DANGER_Y:
		return 0.0
	elif cy >= MAX_DANGER_Y:
		return 1.0
	# get the percent of the y coordinate between the two limits
	var y_percent: float = float(cy - MIN_DANGER_Y) / float(MAX_DANGER_Y - MIN_DANGER_Y)
	# calculate the modifier
	var modifier = lerp(MAX_DANGER_MODIFIER, -MAX_DANGER_MODIFIER, y_percent)
	
	return noise_value - modifier
	
