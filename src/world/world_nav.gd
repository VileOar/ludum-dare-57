extends Node2D

@export var enemy: PackedScene
@export var wall: PackedScene


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
		enemy_spawn_point.add_child.call_deferred(instance)
	
	
## DEBUGGING 
func _add_wall(mouse_pos : Vector2):
	print("add wall")
	var wall_instance = wall.instantiate()
	custom_nav_region.add_child(wall_instance)
	wall_instance.position = mouse_pos
	custom_nav_region.parse_source_geometry()
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
	#if event is InputEventMouseButton:
	#if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var pos = get_local_mouse_position()
		_add_wall(pos)
		
