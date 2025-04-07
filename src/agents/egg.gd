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
	for n in Global.ENEMIES_TO_SPAWN:
		await get_tree().create_timer(Global.TIME_BETWEEN_ENEMY_SPAWNS).timeout
		_instantiate_enemy()


func _instantiate_enemy() -> void:
	var instance = enemy.instantiate()
	egg.add_child.call_deferred(instance)
