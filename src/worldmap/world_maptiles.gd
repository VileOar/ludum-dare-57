class_name WorldMapTiles
extends Node2D

## How many tiles should the bedrock border be.
const BEDROCK_THICKNESS := 8
## The rectangle encompassing the full traverseable map.
const MAP_LIMITS := Rect2i(-25, -20, 50, 100)
## The rectangle encompassing the full map (including bedrock).
const FULL_MAP := Rect2i(
	MAP_LIMITS.position.x - BEDROCK_THICKNESS, 
	MAP_LIMITS.position.y,
	MAP_LIMITS.size.x + BEDROCK_THICKNESS * 2,
	MAP_LIMITS.size.y + BEDROCK_THICKNESS
)
## Total amount of tiles inside playable area
const TOTAL_TILE_AMOUNT: int = MAP_LIMITS.size.x * MAP_LIMITS.size.y
## The dimensions a safe zone (widht,height) in tiles
const SAFE_ZONE_DIMS := Vector2i(9,7)
## Rect representing the starting area (in tiles)
const STARTING_AREA := Rect2i(Vector2i(-4,-3), SAFE_ZONE_DIMS)
## How many safe zones to generate on the map
const SAFE_ZONE_AMOUNT: int = 2
## The minimum distance on the y axis between each safe zone
@warning_ignore("narrowing_conversion")
const SAFE_ZONE_MARGIN: int = SAFE_ZONE_DIMS.y * 2.5

# MAP GENERATION CONSTANTS
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
## How strongly terrain deviates from depth (0 = no variation, 1 = very chaotic)
const TERRAIN_VAR_STRENGTH: float = 0.6

var _safe_zones: Dictionary[Rect2i, Array]

# Dictionary holding the thresholds under which different terrains should spawn.[br]
var _terrain_noise_thresholds := {
	0.2: 0,
	0.5: 1,
	0.8: 2,
	1.0: 3
}

var load_percent: int = 0
var are_tiles_generated: bool = false

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

func _ready() -> void:
	Global.world_map_tiles = self

## Attempt to dig a tile at a position.
func try_dig_tile(pos: Vector2, dig_strength: int) -> bool:
	var cell_pos = _tiles.local_to_map(pos)
	if _tiles.get_cell_tile_data(cell_pos) == null:
		return false
	var can_dig = can_dig_tile(pos, dig_strength)
	if can_dig >= 0:
		_dig_tiles([cell_pos])
	return can_dig >= 0


func is_stable() -> bool:
	return are_tiles_generated


func get_random_spawn_position() -> Vector2:
	var valid_cells = _nav_layer.get_used_cells()
	var cell = valid_cells[Global.rng.randi() % valid_cells.size()]
	return _nav_layer.map_to_local(cell)

func get_tiles() -> MapTiles:
	return _tiles


# Whether the cell at the given position can be dug with given strentgh
func can_dig_tile(pos: Vector2i, dig_strength: int) -> int:
	var cell_pos = _tiles.local_to_map(pos)
	if _tiles.get_cell_tile_data(cell_pos) == null:
		return -1
	var tile_data = _tiles.get_cell_tile_data(cell_pos)
	if tile_data == null:
		return -1
	var hardness = tile_data.get_custom_data("hardness")
	if dig_strength >= hardness:
		return hardness
	return -1


# Method to execute a dig action on group of tile, which removes the tiles and updates necessary data.
func _dig_tiles(cells: Array[Vector2i]):
	for cell in cells:
		# erase danger cells
		for i in _danger_levels:
			BetterTerrain.set_cell(_danger_levels[i], cell, -1)
			BetterTerrain.update_terrain_cell(_danger_levels[i], cell)

		var cell_data = _tiles.get_cell_tile_data(cell)
		if cell_data != null:
			# try to dig a feature tile on position
			_tiles.try_dig_feature(cell)
	_set_cells(cells, -1)

# Internal method to set cells to the terrain tilemap layer
func _set_cells(cells: Array[Vector2i], terrain: int, is_safe: bool = false):
	BetterTerrain.set_cells(_tiles, cells, terrain)
	# if cell is deleted update nearby cells
	if terrain == -1:
		BetterTerrain.update_terrain_cells(_tiles, cells)
	
	for cell in cells:
		if is_safe:
			_nav_layer.set_cell(cell)
		elif terrain == -1:
			_nav_layer.set_cell(cell, 0, Vector2i(9,2))
		else:
			_nav_layer.set_cell(cell)

func generate_tiles():
	var map_seed = randi() # the main seed used to generate everything else
	Global.rng.seed = map_seed
	var danger_seed = Global.rng.randi() # get a different seed for a different noise map
	
	# the noise map for choosing the terrain of each tile
	var terrain_noise = _get_noise_map(map_seed, 0.02, _terrain_noise_thresholds.size(), 0.2)
	# the noise map for choosing the danger level (and spawning ratio) of enemy spawners
	var danger_noise = _get_noise_map(danger_seed, 0.01, 4, 0.0)
	
	var tile_num: int = 0
	# define where the safe zones are going to be
	_generate_safe_zones()
	# set the terrains according to noise
	# also sets the bedrock tiles
	for yy in range(FULL_MAP.position.y, FULL_MAP.end.y):
		for xx in range(FULL_MAP.position.x, FULL_MAP.end.x):
			var cell = Vector2i(xx, yy)
			
			# 1. Bedrock check
			# this means that it is bedrock, so no generation will occur, but filled with bedrock
			if !MAP_LIMITS.has_point(cell):
				_set_cells([cell], 4)
				continue
			
			# 2. Safe zone check
			# if cell is part of a safe zone, add it to the dict
			var safe_zone = _is_cell_in_safe_zone(cell)
			if safe_zone != Rect2i(0,0,0,0):
				_safe_zones[safe_zone].append(cell)
				continue
			
			# 3. Terrain
			var noise = 0.0
			if yy >= TOP_STONE_Y and yy < BOTTOM_STONE_Y:
				# modify the noise value to force stone in the upper layers
				noise = terrain_noise.get_noise_2dv(cell)
				var y_weight: float = float(yy - TOP_STONE_Y) / float(BOTTOM_STONE_Y - TOP_STONE_Y)
				var mod = lerp(2.0, 0.0, y_weight)
				noise = clamp(noise + mod, -1.0, 1.0)
			else:
				# normal terrain generation
				var depth = _get_depth_ratio(yy)
				noise = (terrain_noise.get_noise_2dv(cell) + 1.0) / 2.0
				noise = depth + (noise - 0.5) * TERRAIN_VAR_STRENGTH
				noise = clamp(noise, 0.0, 1.0)
			# generate the terrain tiles, deciding between the different dirt/stone tiles
			var terrain = _noise_to_terrain(noise)
			_set_cells([cell], terrain)
			
			# 4. Danger level
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
	# update map with the safe zones
	_spawn_safe_zones()
	# update terrains once generation ends
	BetterTerrain.update_terrain_area(_tiles, FULL_MAP)
	for i in _danger_levels:
		BetterTerrain.update_terrain_area(_danger_levels[i], FULL_MAP)
	
	are_tiles_generated = true
	Signals.map_stable.emit.call_deferred()

func _is_cell_in_safe_zone(cell) -> Rect2i:
	for safe_zone in _safe_zones.keys():
		if safe_zone.has_point(cell):
			return safe_zone
	return Rect2i(0,0,0,0)

func _generate_safe_zones() -> void:
	_safe_zones[STARTING_AREA] = []
	# how far left and right on the x axis a safe zone rect can generate
	const x_range := Vector2i (
		MAP_LIMITS.position.x + SAFE_ZONE_DIMS.x * 0.5,
		MAP_LIMITS.end.x - SAFE_ZONE_DIMS.x * 1.5
	) 
	# the full range on the y axis available for a safe zone rect to generate
	const y_range := Vector2i (
		STARTING_AREA.position.y + SAFE_ZONE_DIMS.y,
		MAP_LIMITS.end.y - SAFE_ZONE_DIMS.y * 2
	)
	const y_total = y_range.y - y_range.x
	# the height of each vertical "slice" for one safe zone 
	@warning_ignore("integer_division")
	var slice_height = y_total / SAFE_ZONE_AMOUNT
	# generate the safe zones
	for i in range(SAFE_ZONE_AMOUNT):
		var x = randi_range(x_range.x, x_range.y)
		# calculate the current slice start and end
		var y_start = y_range.x + i * slice_height
		var y_end = y_start + slice_height - SAFE_ZONE_DIMS.y
		# apply margin to the top of the slice
		y_start += SAFE_ZONE_MARGIN
		var y = randi_range(y_start,y_end)
		var safe_zone := Rect2i(Vector2i(x,y), SAFE_ZONE_DIMS)
		_safe_zones[safe_zone] = []

# creates a safe zone based on an ordered array of cells
# must follow left to right then top to bot, ex. below
#  1, 2, 3
#  4, 5, 6
#  7, 8, 9
func _create_safe_zone(cells: Array):
	# sizes in cells
	const size_x: int = SAFE_ZONE_DIMS.x
	const size_y: int = SAFE_ZONE_DIMS.y
	# create a navigation obstacle at safe zone
	var obstacle := NavigationObstacle2D.new()
	obstacle.carve_navigation_mesh = true
	obstacle.avoidance_enabled = false
	# buffer shrinks the nav obstacle by a px amount in every direction
	@warning_ignore("integer_division")
	const buffer: int = Global.CELL_SIZE / 2
	# sizes in pixels
	const px_size_x: float = size_x * Global.CELL_SIZE - buffer * 2
	const px_size_y: float = size_y * Global.CELL_SIZE - buffer * 2
	# calculate the nav obstacle's shape
	@warning_ignore("integer_division")
	var start_cell_pos := Vector2i(
		cells[0].x * Global.CELL_SIZE + buffer,
		cells[0].y * Global.CELL_SIZE + buffer,
	)
	var safe_zone_polygon := PackedVector2Array([
		Vector2(
			start_cell_pos.x, 
			start_cell_pos.y),
		Vector2( 
			start_cell_pos.x + px_size_x, 
			start_cell_pos.y),
		Vector2(
			start_cell_pos.x + px_size_x,  
			start_cell_pos.y + px_size_y),
		Vector2(
			start_cell_pos.x,  
			start_cell_pos.y + px_size_y)
	])
	obstacle.vertices = safe_zone_polygon
	# add the nav obstacle to the scene
	add_child(obstacle)
	
	# calculate indices in the middle of the 4 sides of the border
	@warning_ignore("integer_division")
	const entrance_idx: Array[int] = [
		size_x/2 + 1,
		size_x * (size_y/2) + 1,
		size_x * (size_y/2 + 1),
		(size_x * size_y) - size_x/2
	]
	# calculate indices on the border
	var border_idx: Array[int] = []
	for i: int in range(1, size_x * size_y + 1):
		if i <= size_x or i > size_x * (size_y - 1):
			border_idx.append(i)
	for i: int in range(1, size_y - 1):
		border_idx.append(size_x * i + 1)
		border_idx.append(size_x * (i + 1))
	# set cells based on index
	var idx = 1
	for cell: Vector2i in cells:
		if idx in entrance_idx:
			_set_cells([cell], -1)
		elif idx in border_idx:
			_set_cells([cell], 4, true)
		else:
			_set_cells([cell], -1, true)
		idx += 1

func _spawn_safe_zones() -> void:
	for safe_zone in _safe_zones:
		_create_safe_zone(_safe_zones[safe_zone])

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
	

func _get_depth_ratio(cy: int) -> float:
	if cy <= MIN_DANGER_Y:
		return 0.0
	elif cy >= MAX_DANGER_Y:
		return 1.0
	return float(cy - MIN_DANGER_Y) / float(MAX_DANGER_Y - MIN_DANGER_Y)
