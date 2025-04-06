extends Node2D

@onready var egg: Node2D = $"."
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var enemy : PackedScene


func _on_time_to_hatch_timeout() -> void:
	if !enemy:
		print("[Error] No packed scene set on Enemy")
		return
		
	print("Play animation")
	animation_player.play("Explode")
#	Spawns enemies every x time 
	for n in Global.ENEMIES_TO_SPAWN:
		await get_tree().create_timer(Global.TIME_BETWEEN_ENEMY_SPAWNS).timeout
		_instantiate_enemy(egg.global_position)


func _instantiate_enemy(pos: Vector2) -> void:
	var instance = enemy.instantiate()
	instance.position = pos
	egg.add_child.call_deferred(instance)
