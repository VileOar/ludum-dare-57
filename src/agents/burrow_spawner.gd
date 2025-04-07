extends Node2D


@export var enemy : PackedScene

var egg_spawner : Node2D


func _ready() -> void:
	egg_spawner = get_parent()


func _instantiate_enemy() -> void:
	var instance = enemy.instantiate()
	instance.position = position
	Global.enemy_holder.add_child.call_deferred(instance)


func _on_timer_timeout() -> void:
	@warning_ignore("integer_division")
	var enemies_to_spawn = randi_range(Global.ENEMIES_TO_SPAWN_MIN, Global.ENEMIES_TO_SPAWN_MAX) / 2
	for n in enemies_to_spawn:
		await get_tree().create_timer(Global.TIME_BETWEEN_ENEMY_SPAWNS).timeout
		_instantiate_enemy()
	queue_free()
