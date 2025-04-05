extends Node2D

var enemy = preload("res://src/agents/agent.tscn")
@onready var player: CharacterBody2D = $NavigationRegion2D/Player
@onready var enemy_spawn_point: Node2D = $NavigationRegion2D/EnemySpawnPoint

@onready var navigation_region_2d: NavigationRegion2D = $NavigationRegion2D

@export var enemies_to_spawn : int = 10
@export var time_between_spawns = 0.2


func _ready():
	for n in enemies_to_spawn:
		await get_tree().create_timer(time_between_spawns).timeout
		_instantiate_enemy()


func _instantiate_enemy() -> void:
	var instance = enemy.instantiate()
	enemy_spawn_point.add_child(instance)
	instance.set_player_to_chase(player)
	
	
