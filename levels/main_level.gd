extends Node2D

var level_init: bool = false
var _is_game_paused: bool = false
var _is_shop_open: bool = false

var _is_swarm_starting: bool = false

var _egg_scan_counter: int = 0

@export var enemy: PackedScene

@onready var player: CharacterBody2D = %Player
@onready var enemy_holder: Node2D = %EnemyHolder
@onready var custom_nav_region: Node2D = %NavGenerator
@onready var pause_menu: PauseMenu = %PauseMenu
@onready var swarm_start_timer: Timer = %SwarmStartTimer

func _ready() -> void:
	Global.enemy_holder_ref = enemy_holder
	
	Signals.map_stable.connect(_on_map_generated)
	Signals.scan_caught_egg.connect(_on_scan_caught_egg)
	
	# UI signals
	Signals.shop_open.connect(_on_shop_open)
	Signals.shop_close.connect(_on_shop_close)
	Signals.pause_close.connect(_resume_game)
	
	pause_menu.hide()
	
	swarm_start_timer.wait_time = Global.EGG_TIME_TO_HATCH + 0.5

func _process(_delta: float) -> void:
	if (!level_init):
		level_init = true
		Global.world_map_tiles_ref.generate_tiles()
		Global.player_ref.set_radar_pulse($RadarPulse)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("CloseMenu"):
		_on_pause_key_press()

func _on_map_generated() -> void:
	$CanvasLayer/LoadingMsg.hide()

func _on_shop_open() -> void:
	_is_shop_open = true
	_block_player()

func _on_shop_close() -> void:
	_is_shop_open = false
	_unblock_player()

func _block_player() -> void:
	Global.player_ref.set_can_play(false)

func _unblock_player() -> void:
	Global.player_ref.set_can_play(true)

func _on_pause_key_press() -> void:
	if !_is_game_paused and !_is_shop_open:
		_pause_game()
	elif pause_menu.can_be_closed():
		_resume_game()

func _pause_game() -> void:
	_is_game_paused = true
	pause_menu.show()
	_block_player()
	Engine.time_scale = 0

func _resume_game() -> void:
	_is_game_paused = false
	pause_menu.hide()
	_unblock_player()
	Engine.time_scale = 1

func _on_scan_caught_egg(pos: Vector2) -> void:
	if _is_swarm_starting or _is_swarm_active():
		return
	
	_egg_scan_counter += 1
	if _egg_scan_counter >= Global.SCANS_BEFORE_SWARM:
		_egg_scan_counter = 0
		Signals.spawn_burrow.emit(pos)
		_is_swarm_starting = true
		swarm_start_timer.start()
	
	Global.hud_ref.show_swarm_warning()

func _is_swarm_active() -> bool:
	if not enemy_holder:
		return false
	return enemy_holder.get_child_count() > 0


func _on_swarm_start_timer_timeout() -> void:
	_is_swarm_starting = false
