extends Node2D

@onready var egg: Node2D = $"."
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var enemy : PackedScene


func _ready() -> void:
	animation_player.active = true
	animation_player.play("Shake")
	

func _on_time_to_hatch_timeout() -> void:
	if !enemy:
		print("[Error] No packed scene set on Enemy")
		return
		
	animation_player.play("Explode")
#	Spawns enemies every x time 
	var enemies_to_spawn = randi_range(Global.ENEMIES_TO_SPAWN_MIN, Global.ENEMIES_TO_SPAWN_MAX)
	for n in enemies_to_spawn:
		await get_tree().create_timer(Global.TIME_BETWEEN_ENEMY_SPAWNS).timeout
		_instantiate_enemy(egg.position)


func _instantiate_enemy(pos: Vector2) -> void:
	var instance = enemy.instantiate()
	instance.position = Vector2.ZERO
	egg.add_child.call_deferred(instance)
