extends Node2D

@onready var egg: Node2D = $"."
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var time_to_hatch: Timer = $TimeToHatch

@export var enemy : PackedScene

var egg_spawner : Node2D 


func _ready() -> void:
	animation_player.active = true
	animation_player.play("Shake")
	egg_spawner = get_parent()
	egg_spawner.egg_was_found.connect(_egg_triggered_to_spawn_enemies)


# TODO test
func _egg_triggered_to_spawn_enemies() -> void:
	print("_egg_triggered_to_spawn_enemies")
	animation_player.active = true
	animation_player.play("Shake")
	time_to_hatch.start()
	

func _on_time_to_hatch_timeout() -> void:
	if !enemy:
		print("[Error] No packed scene set on Enemy")
		return
		
	animation_player.play("Explode")
#	Spawns enemies every x time 
	var enemies_to_spawn = randi_range(Global.ENEMIES_TO_SPAWN_MIN, Global.ENEMIES_TO_SPAWN_MAX)
	for n in enemies_to_spawn:
		await get_tree().create_timer(Global.TIME_BETWEEN_ENEMY_SPAWNS).timeout
		_instantiate_enemy()


func _instantiate_enemy() -> void:
	var instance = enemy.instantiate()
	instance.position = position
	Global.enemy_holder.add_child.call_deferred(instance)
