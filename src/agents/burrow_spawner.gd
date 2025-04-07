extends Node2D


@export var enemy : PackedScene

var egg_spawner : Node2D


func _ready() -> void:
	egg_spawner = get_parent()


func _instantiate_enemy() -> void:
	var instance = enemy.instantiate()
	instance.position = position
	egg_spawner.add_child.call_deferred(instance)


func _on_timer_timeout() -> void:
	_instantiate_enemy()
	queue_free()
