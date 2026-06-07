class_name Enemy
extends CharacterBody2D

var _is_following_player: bool = true

var _origin_point: Vector2
var _parent_egg: Egg

@onready var _nav_agent: NavigationAgent2D = $NavigationAgent2D


func _ready():
	_origin_point = global_position
	_update_nav_target()


func _physics_process(_delta: float) -> void:
	if _nav_agent.is_navigation_finished():
		return
	
	var next_path_position = _nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_position)
	
	_nav_agent.velocity = direction * Global.ENEMY_SPEED


func enemy_collided_with_player() -> void:
	_destroy()


func set_parent_egg(egg: Egg) -> void:
	_parent_egg = egg


func _update_nav_target() -> void:
	var nav_map := _nav_agent.get_navigation_map()
	var closest_point := NavigationServer2D.map_get_closest_point(nav_map, _get_nav_target())
	_nav_agent.target_position = closest_point


func _on_nav_finished():
	if !_is_following_player:
		# When it reachs spawn point, disappears
		if global_position.distance_to(_origin_point) < Global.CELL_SIZE/4.0:
			_destroy()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_update_path_timeout() -> void:
	_update_nav_target()


func _on_give_up_timeout() -> void:
	_is_following_player = false
	_update_nav_target()


func _get_nav_target() -> Vector2:
	if _is_following_player:
		if Global.player_ref:
			return Global.player_ref.global_position
		else:
			print_debug("[Warning] Player reference not set!")
	
	return _origin_point


func _destroy() -> void:
	if _parent_egg:
		_parent_egg.remove_enemy()
	queue_free()
