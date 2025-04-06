extends Node2D

var _tile_size: int = 128  # devíamos guardar isto no equivalente a uma global readonly variable
var _level: int = 0
var _is_active: bool = false
var _active_time: float = 0.0
var _pulse_size: int = 3 * _tile_size

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.material.set_shader_parameter("tile_size", _tile_size)
	increase_level()

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_1):
		activate()
	
	if _is_active:
		_active_time = _active_time + delta
		
		if _active_time < 1.0:
			color_rect.material.set_shader_parameter("time", _active_time)
		else:
			_active_time = 0
			_is_active = false

func increase_level() -> void:
	_level += 1
	_pulse_size = (3 + (2 * _level)) * _tile_size
	color_rect.size = Vector2(_pulse_size, _pulse_size)
	color_rect.material.set_shader_parameter("pulse_size", _pulse_size)

func activate() -> void:
	if not _is_active:
		_is_active = true
		AudioController.play_radar_pulse()
