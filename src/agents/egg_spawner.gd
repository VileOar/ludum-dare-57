extends Node2D

@onready var enemy_holder: Node2D = %EnemyHolder
@onready var egg_spawner: Node2D = $"."
@export var egg : PackedScene
@export var burrow : PackedScene

signal egg_was_found

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
	_egg_found()


func _on_spawn_egg_signal(pos: Vector2):
	instantiate_thing(egg, pos)


func _on_spawn_burrow_signal(pos: Vector2):
	instantiate_thing(burrow, pos)


func _egg_found() -> void:
	egg_was_found.emit()
