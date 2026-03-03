extends Node2D

var generate_called: bool = false

@export var enemy: PackedScene
@onready var player: CharacterBody2D = %Player
@onready var enemy_holder: Node2D = %EnemyHolder
@onready var custom_nav_region: Node2D = %NavGenerator

func _ready() -> void:
	Global.enemy_holder = enemy_holder
	Signals.map_stable.connect(_on_map_generated)

func _process(_delta: float) -> void:
	if (!generate_called):
		generate_called = true
		Global.world_map_tiles._generate_tiles()

func _on_map_generated() -> void:
	$CanvasLayer/LoadingMsg.hide()
