extends Node2D
class_name RadarPulse

var _level: int = 1
var _is_active: bool = false
var _active_time: float = 0.0
var _pulse_size: int = Global.CELL_SIZE

@onready var color_rect: ColorRect = $ColorRect
@onready var detector: Area2D = $Detector

func _ready() -> void:
	color_rect.material.set_shader_parameter("tile_size", Global.CELL_SIZE)
	_set_level(1)

func _process(delta: float) -> void:
	if _is_active:
		_active_time = _active_time + delta
		
		if _active_time < 1.0:
			color_rect.material.set_shader_parameter("time", _active_time)
		else:
			_active_time = 0
			_is_active = false

func _set_level(level) -> void:
	_level = level
	_pulse_size = (4 + (2 * _level)) * Global.CELL_SIZE
	color_rect.material.set_shader_parameter("pulse_size", _pulse_size)
	color_rect.size = Vector2(_pulse_size, _pulse_size)
	@warning_ignore("integer_division")
	var pos = -_pulse_size/2
	color_rect.position = Vector2(pos, pos)

func increase_level() -> void:
	_set_level(_level + 1)

func activate() -> bool:
	var success:bool = false
	if not _is_active:
		_is_active = true
		AudioController.play_radar_pulse()
		success = true
	return success
