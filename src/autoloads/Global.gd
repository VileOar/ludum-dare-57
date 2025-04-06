extends Node

const CELL_SIZE = 128
const  MAX_MINING_STRENGTH: int = 4

var rng: RandomNumberGenerator

# Reference to the world map tiles scene
var world_map_tiles: WorldMapTiles

func _ready() -> void:
	randomize()
	rng = RandomNumberGenerator.new()
