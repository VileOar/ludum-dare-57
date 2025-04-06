extends Node2D


## The rectangle encompassing the full traverseable map
const MAP_LIMITS := Rect2i(0, 0, 15, 8)


@onready var _tiles: MapTiles = $MapTiles

# Dictionary holding the thresholds under which different terrains should spawn.[br]
var _terrain_noise_thresholds := {
	0.2: 0,
	0.5: 1,
	0.8: 2,
	1.0: 3
}


func _ready() -> void:
	_generate_tiles()


## TODO: remove
func _physics_process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var cell = _tiles.get_local_mouse_position()
		cell = Vector2i(cell/Global.CELL_SIZE)
		dig_tiles([cell])


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
	var terrain_noise = _get_noise_map(map_seed, 0.16, _terrain_noise_thresholds.size(), 0.2)
	# the noise map for choosing the danger level (and spawning ratio) of enemy spawners
	var danger_noise = _get_noise_map(danger_seed, 0.02, 4, 0.0)
	
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
			
			var col_val = (danger_noise.get_noise_2dv(cell) + 1.0)/2.0
			_tiles.update_tile(cell, func(tile_data: TileData): tile_data.modulate = Color.from_hsv(0.0, 0.0, col_val))
	_tiles.force_update_tiles()


func _get_noise_map(noise_seed: float, frequency: float, fractal_octaves: int, fractal_gain: float) -> FastNoiseLite:
	var simplex_noise = FastNoiseLite.new()
	
	simplex_noise.seed = noise_seed
	
	simplex_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	simplex_noise.frequency = frequency
	simplex_noise.fractal_octaves = fractal_octaves
	simplex_noise.fractal_gain = fractal_octaves
	
	return simplex_noise


# Get the appropriate terrain id based on the given noise value.[br]
# Returns the first terrain, where the asrgument is lower than the respective key
func _noise_to_terrain(noise_value: float) -> int:
	var fallback = -1
	for key in _terrain_noise_thresholds:
		fallback = _terrain_noise_thresholds[key]
		if noise_value <= key:
			return fallback
	return fallback
