extends Node2D


# TODO: remove
const CELL_W: int = 15
const CELL_H: int = 8


@onready var _dirt: TileMapLayer = $Dirt

# Dictionary holding the thresholds under which different terrains should spawn.[br]
var _terrain_noise_thresholds := {
	-0.4: -1,
	-0.2: -1,
	0.0: 0,
	1.0: -1
}


func _ready() -> void:
	_generate_tiles()


## TODO: remove
func _physics_process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var cell = _dirt.get_local_mouse_position()
		cell = Vector2i(cell/Global.CELL_SIZE)
		dig_tiles([cell])


## Method to execute a dig action on group of tile, which removes the tiles and updates necessary data.
func dig_tiles(cells: Array[Vector2i]):
	_set_cells(cells, -1)


func _set_cells(cells: Array[Vector2i], terrain):
	_dirt.set_cells_terrain_connect(cells, 0, terrain)


func _generate_tiles():
	var noise_map = _get_noise_generator(randi())
	
	for yy in CELL_H:
		for xx in CELL_W:
			var terrain = _noise_to_terrain(noise_map.get_noise_2d(xx, yy))
			_set_cells([Vector2i(xx, yy)], terrain)


func _get_noise_generator(seed: float) -> FastNoiseLite:
	var simplex_noise = FastNoiseLite.new()
	
	simplex_noise.seed = seed
	
	simplex_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
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
