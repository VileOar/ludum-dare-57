extends Node2D

var _level: int = 1
var _is_active: bool = false
var _active_time: float = 0.0
var _pulse_size: int = (4 + (2 * _level)) * Global.CELL_SIZE

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.material.set_shader_parameter("tile_size", Global.CELL_SIZE)
	color_rect.size = Vector2(_pulse_size, _pulse_size)
	var pos = -_pulse_size/2.0
	color_rect.position = Vector2(pos, pos)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("RadarPulse"):
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
	_pulse_size = (4 + (2 * _level)) * Global.CELL_SIZE
	color_rect.material.set_shader_parameter("pulse_size", _pulse_size)
	color_rect.size = Vector2(_pulse_size, _pulse_size)
	var pos = -_pulse_size/2
	color_rect.position = Vector2(pos, pos)

func activate() -> void:
	if not _is_active:
		_is_active = true
		AudioController.play_radar_pulse()
