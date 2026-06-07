extends StaticBody2D
class_name Egg

var _is_active: bool = false
var _is_interactable: bool = false
var _is_going_to_be_destroyed: bool = false

## The current number of active enemies spawned by this egg
var _active_enemies: int = 0

@export var enemy_scene : PackedScene

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _time_to_hatch: Timer = $TimeToHatch
@onready var _interact_ui: Control = $InteractPrompt


func _init() -> void:
	add_to_group(Global.INTERACTABLE_GROUP)


func _ready() -> void:
	_time_to_hatch.wait_time = Global.EGG_TIME_TO_HATCH
	_animation_player.active = true
	_animation_player.play("Shake")
	$InteractPrompt/CostLabel.text = str(Global.EGG_DESTROY_COST)


func remove_enemy() -> void:
	_active_enemies -= 1
	if _active_enemies <= 0:
		_is_active = false
		_is_interactable = true


func spawn_enemies() -> void:
	if _is_active:
		return
	
	_is_active = true
	_is_interactable = false
	
	_animation_player.active = true
	_animation_player.play("Shake")
	_time_to_hatch.start()


func _on_time_to_hatch_timeout() -> void:
	if !enemy_scene:
		print("[Error] No packed scene set on Enemy")
		return
	
	_animation_player.play("Explode")
	#Spawns enemies every x time 
	var enemies_to_spawn = randi_range(Global.ENEMIES_TO_SPAWN_MIN, Global.ENEMIES_TO_SPAWN_MAX)
	for i in range(enemies_to_spawn):
		_instantiate_enemy()
		await get_tree().create_timer(Global.TIME_BETWEEN_ENEMY_SPAWNS).timeout


func _instantiate_enemy() -> void:
	var instance: Enemy = enemy_scene.instantiate()
	instance.position = position
	instance.set_parent_egg(self)
	_active_enemies += 1
	Global.enemy_holder_ref.add_child.call_deferred(instance)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Destroy" and _is_going_to_be_destroyed:
		queue_free()


#region Interaction
func enter_interaction() -> void:
	if _is_interactable:
		_interact_ui.visible = true
		_interact_ui.play_animation()


func interact() -> void:
	if _is_interactable and Global.get_currency() >= Global.EGG_DESTROY_COST:
		Global.set_currency(-Global.EGG_DESTROY_COST)
		_animation_player.active = true
		_animation_player.play("Destroy")
		_is_going_to_be_destroyed = true
		exit_interaction()
		_is_interactable = false


func exit_interaction() -> void:
	if _is_interactable:
		_interact_ui.visible = false
		_interact_ui.stop_animation()
#endregion
