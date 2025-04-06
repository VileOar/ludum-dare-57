extends Node2D

var enemy = preload("res://src/agents/agent.tscn")
var wall = preload("res://src/temp/wall_tmp.tscn")

@onready var player: CharacterBody2D = $CustomNavRegion/Player
@onready var enemy_spawn_point: Node2D = $CustomNavRegion/EnemySpawnPoint
@onready var custom_nav_region: Node2D = $CustomNavRegion


func _ready():
	for n in Global.ENEMIES_TO_SPAWN:
		await get_tree().create_timer(Global.TIME_BETWEEN_ENEMY_SPAWNS).timeout
		_instantiate_enemy()


func _instantiate_enemy() -> void:
	var instance = enemy.instantiate()
	if enemy_spawn_point:
		instance.set_player_to_chase(player)
		enemy_spawn_point.add_child(instance)
	
	
## DEBUGGING 
func _add_wall(mouse_pos : Vector2):
	var wall_instance = wall.instantiate()
	custom_nav_region.add_child(wall_instance)
	wall_instance.position = mouse_pos
	custom_nav_region.parse_source_geometry()
	
	
#	Puts wall on mouse click
func _input(event):
	if event is InputEventMouseButton:
		_add_wall(event.position)
	
	
