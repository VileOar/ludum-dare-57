class_name Enemy
extends CharacterBody2D

@onready var agent: CharacterBody2D = $"."
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@export var player_to_chase: CharacterBody2D

var is_give_up_time : bool = false
var origin_point : Vector2


func _ready():
	origin_point = agent.position
	nav_agent.navigation_finished.connect(_on_nav_finished)
	nav_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	set_player_to_chase()
	make_path(_get_player_location())
#	Sets target position as origin when starting
	nav_agent.target_position = origin_point



func _physics_process(_delta: float) -> void:
	# validate 
	if nav_agent && !player_to_chase:
		return
	# If agent is on player, doesn't jitter
	if agent.global_position == player_to_chase.global_position:
		return
		
	var next_path_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	var new_velocity = direction * Global.ENEMY_SPEED 
	
	nav_agent.velocity = new_velocity
	velocity = new_velocity
	
	
# When it reachs the target location, gets new one
func _on_nav_finished():
#	When it reachs spawn point, dissapears
	if is_give_up_time:
		queue_free()
	
	
func _on_navigation_agent_2d_velocity_computed(safe_velocity) -> void:
	velocity = velocity.move_toward(safe_velocity, 100)
	move_and_slide()


func _on_update_player_location_timeout() -> void:
	make_path(_get_player_location())


func _on_time_to_give_up_timeout() -> void:
	is_give_up_time = true


func _get_player_location() -> Vector2:
	if is_give_up_time:
		return origin_point

	if player_to_chase:
		return player_to_chase.global_position
	else:
		print_debug("[Warning] Player to Chase Not Set!")
		# Inside the region, random place
		return Vector2(randf_range(0, get_viewport_rect().size.x), randf_range(0, get_viewport_rect().size.y))
		
	
func enemy_collided_with_player() -> void:
	queue_free()
	
	
func make_path(pos: Vector2) -> void:
	nav_agent.target_position = pos
		
		
func set_player_to_chase():
	player_to_chase	= Global.player_ref
