extends StaticBody2D

@onready var egg: StaticBody2D = $"."
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var time_to_hatch: Timer = $TimeToHatch
@onready var _time_to_destroy: Timer = $TimeToDestroy
@onready var _interact_ui: Control = $InteractPrompt

@export var enemy : PackedScene

var egg_spawner : Node2D 

var _is_interactable: bool = false
var _is_going_to_be_destroyed: bool = false

func _init() -> void:
	add_to_group(Global.INTERACTABLE_GROUP)

func _ready() -> void:
	animation_player.active = true
	animation_player.play("Shake")
	egg_spawner = get_parent()
	egg_spawner.egg_was_found.connect(_egg_triggered_to_spawn_enemies)
	$InteractPrompt/CostLabel.text = str(Global.EGG_DESTROY_COST)

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
	_time_to_destroy.start()

func _instantiate_enemy() -> void:
	var instance = enemy.instantiate()
	egg.add_child.call_deferred(instance)

func enter_interaction() -> void:
	if _is_interactable:
		_interact_ui.visible = true
		_interact_ui.play_animation()

func interact() -> void:
	if _is_interactable and Global.get_currency() >= Global.EGG_DESTROY_COST:
		Global.set_currency(-Global.EGG_DESTROY_COST)
		animation_player.active = true
		animation_player.play("Destroy")
		_is_going_to_be_destroyed = true
		exit_interaction()
		_is_interactable = false

func exit_interaction() -> void:
	if _is_interactable:
		_interact_ui.visible = false
		_interact_ui.stop_animation()

func _on_time_to_destroy_timeout() -> void:
	_is_interactable = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Destroy" and _is_going_to_be_destroyed:
		queue_free()
