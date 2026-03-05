class_name Enemy
extends CharacterBody2D

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@export var player_to_chase: CharacterBody2D

var is_give_up_time : bool = false
var origin_point : Vector2


func _ready():
	origin_point = position
	nav_agent.navigation_finished.connect(_on_nav_finished)
	nav_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	set_player_to_chase()
	make_path(_get_player_location())
#	Sets target position as origin when starting
	nav_agent.target_position = origin_point


func _physics_process(_delta: float) -> void:
	if not player_to_chase:
		return

	if nav_agent.is_navigation_finished():
		return

	var next_path_position = nav_agent.get_next_path_position()
	var direction = position.direction_to(next_path_position)

	nav_agent.velocity = direction * Global.ENEMY_SPEED
	
	
# When it reachs the target location, gets new one
func _on_nav_finished():
#	When it reachs spawn point, dissapears
	if is_give_up_time:
		if position.distance_to(origin_point) < Global.CELL_SIZE/4.0:
			queue_free()
	
	
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_update_player_location_timeout() -> void:
	make_path(_get_player_location())


func _on_time_to_give_up_timeout() -> void:
	is_give_up_time = true


func _get_player_location() -> Vector2:
	if is_give_up_time:
		return origin_point

	if player_to_chase:
		return player_to_chase.position
	else:
		print_debug("[Warning] Player to Chase Not Set!")
		# Inside the region, random place
		return Vector2(randf_range(0, get_viewport_rect().size.x), randf_range(0, get_viewport_rect().size.y))
		
	
func enemy_collided_with_player() -> void:
	queue_free()
	
	
func make_path(pos: Vector2) -> void:
	var target = _get_target(pos)
	nav_agent.target_position = target
		
		
func set_player_to_chase():
	player_to_chase = Global.player_ref

func _get_target(target_pos: Vector2)-> Vector2:
	var nav_map := nav_agent.get_navigation_map()
	var closest_point := NavigationServer2D.map_get_closest_point(nav_map, target_pos)
	return closest_point
