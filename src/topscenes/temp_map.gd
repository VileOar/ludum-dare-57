extends Node2D


## The rectangle encompassing the full traverseable map
const MAP_LIMITS := Rect2i(-15, -8, 30, 16)

# TODO: change
## The y value above which danger should effectively be 0
const MIN_DANGER_Y = -8
## The y value below which danger should effectively be 1
const MAX_DANGER_Y = 8
## the max value to add/subtract to the danger value, depending on y coordinate
const MAX_DANGER_MODIFIER = 0.5

## The hue to be used for the danger indication
const BASE_DANGER_HUE := 0.74
## The minimum colour brightness, relative to danger tiles
const MIN_COLOR_BRI := 0.2

@onready var _tiles: MapTiles = $MapTiles

# Dictionary holding the thresholds under which different terrains should spawn.[br]
var _terrain_noise_thresholds := {
	0.3: 0,
	0.6: 1,
	0.8: 2,
	1.0: 3
}


func _ready() -> void:
	_generate_tiles()


## TODO: remove
func _physics_process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = _tiles.get_local_mouse_position()
		var cell = _tiles.local_to_map(mouse_pos)
		dig_tiles([cell])
	
	if Input.is_key_pressed(KEY_W):
		$Camera2D.position.y -= 320 * delta
	if Input.is_key_pressed(KEY_S):
		$Camera2D.position.y += 320 * delta
	if Input.is_key_pressed(KEY_A):
		$Camera2D.position.x -= 320 * delta
	if Input.is_key_pressed(KEY_D):
		$Camera2D.position.x += 320 * delta


## Method to execute a dig action on group of tile, which removes the tiles and updates necessary data.
func dig_tiles(cells: Array[Vector2i]):
	_set_cells(cells, -1)
	_tiles.force_update_tiles()


func _set_cells(cells: Array[Vector2i], terrain):
	_tiles.set_cells_terrain_connect(cells, 0, terrain)


func _generate_tiles():
	var map_seed = randi() # the main seed used to generate everything else
	Global.rng.seed = map_seed
	var danger_seed = Global.rng.randi() # get a different seed for a different noise map
	
	# the noise map for choosing the terrain of each tile
	var terrain_noise = _get_noise_map(map_seed, 0.02, _terrain_noise_thresholds.size(), 0.2)
	# the noise map for choosing the danger level (and spawning ratio) of enemy spawners
	var danger_noise = _get_noise_map(danger_seed, 0.01, 4, 0.0)
	
	# set the terrains according to noise
	for yy in range(MAP_LIMITS.position.y, MAP_LIMITS.end.y):
		for xx in range(MAP_LIMITS.position.x, MAP_LIMITS.end.x):
			var cell = Vector2i(xx, yy)
			
			var terrain = _noise_to_terrain(terrain_noise.get_noise_2dv(cell))
			_set_cells([cell], terrain)
	
	# must run again not to interfere with the autotiling adjustments
	for yy in range(MAP_LIMITS.position.y, MAP_LIMITS.end.y):
		for xx in range(MAP_LIMITS.position.x, MAP_LIMITS.end.x):
			var cell = Vector2i(xx, yy)
			
			var danger_level = (danger_noise.get_noise_2dv(cell) + 1.0)/2.0
			danger_level = clamp(_get_danger_level(danger_level, yy), 0.0, 1.0)
			# adapt it to be above the minimum brightness value and calculate saturation
			var col := _get_danger_colour(danger_level)
			
			_tiles.update_tile(cell, func(tile_data: TileData): tile_data.modulate = col)
			
			# TODO: check spawn enemies
	_tiles.force_update_tiles()


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


# Get a color value to use in cell modulate according to its danger level (0 - 1)
func _get_danger_colour(danger_ratio: float) -> Color:
	danger_ratio = 1 - snapped(danger_ratio, 0.2)
	return Color.from_hsv(
		BASE_DANGER_HUE,
		max(0.0, lerp(1.0, -0.6, danger_ratio)),
		lerp(MIN_COLOR_BRI, 1.0, danger_ratio))


# Calculate a danger value from the descending danger rule and a noise value (0 - 1)[br]
# Also depends on the cell y coordinate
func _get_danger_level(noise_value: float, cy: int) -> float:
	# get the percent of the y coordinate between the two limits
	var y_percent: float = float(cy - MIN_DANGER_Y) / float(MAX_DANGER_Y - MIN_DANGER_Y)
	# calculate the modifier
	var modifier = lerp(MAX_DANGER_MODIFIER, -MAX_DANGER_MODIFIER, y_percent)
	
	return noise_value - modifier
