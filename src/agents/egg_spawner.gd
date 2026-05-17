extends Node2D

## Contais all spawned eggs on the map
var _eggs: Array[Egg] = []

@export var egg_scene : PackedScene
@export var burrow : PackedScene

@onready var enemy_holder: Node2D = %EnemyHolder
@onready var egg_spawner: Node2D = $"."

func _ready() -> void:
	Signals.spawn_egg.connect(_on_spawn_egg_signal)
	Signals.spawn_burrow.connect(_on_spawn_burrow_signal)


func instantiate_thing(packed_scene, pos: Vector2) -> void:
	if !packed_scene:
		print("[Error] No packed scene set on Egg")
		return
		
	var instance = packed_scene.instantiate()
	instance.position = pos
	
	egg_spawner.add_child.call_deferred(instance)
	
	if instance is Egg:
		_register_egg(instance)
		_trigger_eggs_in_range(instance.global_position, Global.EGG_ALERT_RADIUS)


func _register_egg(egg: Egg) -> void:
	_eggs.append(egg)
	
	# Automatically unregister destroyed eggs
	egg.tree_exited.connect(
		func():
			_eggs.erase(egg)
	)


func _trigger_eggs_in_range(pos: Vector2, radius: int) -> void:
	for egg in _eggs:
		if !is_instance_valid(egg):
			continue
		
		var distance = egg.global_position.distance_to(pos)
		
		if distance <= radius:
			egg.spawn_enemies.call_deferred()


func _on_spawn_egg_signal(pos: Vector2):
	instantiate_thing(egg_scene, pos)


func _on_spawn_burrow_signal(pos: Vector2):
	@warning_ignore("integer_division")
	const radius_in_tiles = roundi(Global.EGG_ALERT_RADIUS / Global.CELL_SIZE)
	
	var spawn_pos = Global.world_map_tiles_ref.get_spawn_position_near(pos, radius_in_tiles)
	
	instantiate_thing(burrow, spawn_pos)
	_trigger_eggs_in_range(pos, Global.get_pulse_size())
