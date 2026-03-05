extends Node2D

var level_init: bool = false

@export var enemy: PackedScene
@onready var player: CharacterBody2D = %Player
@onready var enemy_holder: Node2D = %EnemyHolder
@onready var custom_nav_region: Node2D = %NavGenerator

func _ready() -> void:
	Global.enemy_holder = enemy_holder
	Signals.map_stable.connect(_on_map_generated)
	Signals.shop_open.connect(_on_shop_open)
	Signals.shop_close.connect(_on_shop_close)

func _process(_delta: float) -> void:
	if (!level_init):
		level_init = true
		Global.world_map_tiles.generate_tiles()
		Global.player_ref.set_radar_pulse($RadarPulse)

func _on_map_generated() -> void:
	$CanvasLayer/LoadingMsg.hide()

func _on_shop_open() -> void:
	Global.player_ref.set_can_play(false)

func _on_shop_close() -> void:
	Global.player_ref.set_can_play(true)
