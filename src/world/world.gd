extends Node2D

var enemy = preload("res://src/agents/agent.tscn")
var wall = preload("res://src/temp/wall_tmp.tscn")
@onready var player: CharacterBody2D = $NavigationRegion2D/Player
@onready var enemy_spawn_point: Node2D = $NavigationRegion2D/EnemySpawnPoint

@export var enemies_to_spawn : int = 10
@export var time_between_spawns = 0.2



func _ready():
	for n in enemies_to_spawn:
		await get_tree().create_timer(time_between_spawns).timeout
		_instantiate_enemy()


func _instantiate_enemy() -> void:
	var instance = enemy.instantiate()
	if enemy_spawn_point:
		enemy_spawn_point.add_child(instance)
		instance.set_player_to_chase(player)
	
	
## DEBUGGING 

func _random_place() -> Vector2:
	return Vector2(randf_range(0, get_viewport_rect().size.x), randf_range(0, get_viewport_rect().size.y))


func _add_wall():
	var wall_instance = wall.instantiate()
	#custom_nav_region.add_child(wall_instance)
	#wall_instance.position = _random_place()
	
	
func _input(_inp):
	if Input.is_key_pressed(KEY_0):
		_add_wall()
	
	
	
