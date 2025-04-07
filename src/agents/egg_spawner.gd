extends Node2D

@onready var egg_spawner: Node2D = $"."
@export var egg : PackedScene

signal egg_was_found

func instantiate_egg(pos: Vector2) -> void:
	if !egg:
		print("[Error] No packed scene set on Egg")
		return
		
	var instance = egg.instantiate()
	instance.position = pos
	egg_spawner.add_child.call_deferred(instance)


func _egg_found() -> void:
	egg_was_found.emit()
