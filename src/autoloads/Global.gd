extends Node

const CELL_SIZE = 128

var rng: RandomNumberGenerator


func _ready() -> void:
	randomize()
	rng = RandomNumberGenerator.new()
