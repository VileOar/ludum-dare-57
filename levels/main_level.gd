extends Node2D

@export var enemy: PackedScene

@onready var player: CharacterBody2D = %Player
@onready var enemy_holder: Node2D = %EnemyHolder
@onready var custom_nav_region: Node2D = %NavGenerator

func _ready() -> void:
	Global.enemy_holder = enemy_holder
