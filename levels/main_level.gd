extends Node2D

@export var enemy: PackedScene

@onready var player: CharacterBody2D = %Player
@onready var enemy_holder: Node2D = %EnemyHolder
@onready var custom_nav_region: Node2D = %NavGenerator


func _instantiate_enemy(pos: Vector2) -> void:
	var instance = enemy.instantiate()
	if enemy_holder:
		instance.position = pos
		instance.set_player_to_chase(player)
		enemy_holder.add_child.call_deferred(instance)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var pos = get_local_mouse_position()
		_instantiate_enemy(pos)
