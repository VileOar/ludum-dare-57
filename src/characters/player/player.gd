extends CharacterBody2D
class_name Player

# Maximum move speed of the player
const _MAX_MOVE_SPEED: float = 4 * Global.CELL_SIZE
# Player movement acceleration
const _ACCELERATION: float = 20 * Global.CELL_SIZE
# Player movement friction
const _FRICTION: float = 40 * Global.CELL_SIZE
# List of possible input directions
const _POSSIBLE_INPUT_DIRS = ["MoveLeft", "MoveRight", "MoveUp", "MoveDown"]
# How far from a tile the the player tries to mine
const _MINING_RANGE = Global.CELL_SIZE/2

# Movement
# Stores last movement direction on x axis
var _was_moving_left: bool = false
# Stores current input direction
var _current_input: Vector2 = Vector2.ZERO
# Stores a priority value for each input (lower = higher priority)
var _input_order: Dictionary = {
"MoveLeft" = 0, 
"MoveRight" = 0, 
"MoveUp" = 0, 
"MoveDown" = 0}

var _health: int
var _fuel: int
var _mining_strength: int = 0

var available_interactables: Array = []
var current_interactable = null 

@onready var _player_sprite: AnimatedSprite2D = $Sprite 
@onready var _mining_check_ray: RayCast2D = $MiningCheckRay

var can_play = false

func _ready() -> void:
	Global.player_ref = self

	_health = Global.max_health
	_fuel = Global.max_fuel

	if Global.world_map_tiles:
		Global.world_map_tiles.try_dig_tile(position, Global.MAX_MINING_STRENGTH)


func _input(event):
	if event.is_action_pressed("Interact") && !available_interactables.is_empty():
		current_interactable.interact()

func _unhandled_input(_event: InputEvent) -> void:
	_current_input = _get_input()

func _physics_process(delta: float) -> void:
	if can_play:
		_move(_current_input, delta)
		_try_to_mine(_current_input)

func _process(_delta: float) -> void:
	# If multiple interactables are available to the player then
	# check which one is closer and set it as current
	if available_interactables.size() > 1:
		var closest_interactable
		
		for interactable in available_interactables:
			if (interactable.position.distance_to(position) < 
			current_interactable.position.distance_to(position)):
				closest_interactable = interactable
				
		if closest_interactable:
			current_interactable.exit_interaction()
			closest_interactable.enter_interaction()
			current_interactable = closest_interactable

	if can_play:
		_update_sprite(_current_input)
	else: 
		if Global.world_map_tiles.are_tiles_generated:
			can_play = true

# Updates player velocity based on the input direction
func _move(input_dir: Vector2, delta: float) -> void:
	if input_dir: 
		velocity = velocity.move_toward(input_dir * _MAX_MOVE_SPEED , delta * _ACCELERATION)
	else: 
		velocity = velocity.move_toward(Vector2(0,0), delta * _FRICTION)
	
	move_and_slide();

# Update ray cast position to face movement direction and try to mine in that direction
func _try_to_mine(input_dir: Vector2) -> void:
	_mining_check_ray.target_position = input_dir * _MINING_RANGE
	if _mining_check_ray.is_colliding() and Global.world_map_tiles:
		Global.world_map_tiles.try_dig_tile(to_global(_mining_check_ray.target_position), _mining_strength)

# Updates sprite flip and rotation based on input vector
func _update_sprite(input_dir: Vector2) -> void:
	if input_dir:
		if _player_sprite.animation != "Mine":
			_player_sprite.play("Mine")
	else:
		if _player_sprite.animation != "Idle":
			_player_sprite.play("Idle")
	
	if input_dir.x == -1:
			_player_sprite.flip_h = true
			_player_sprite.flip_v = false
			_was_moving_left = true
			_player_sprite.rotation_degrees = 0
	elif input_dir.x == 1:
			_player_sprite.flip_h = false
			_player_sprite.flip_v = false
			_was_moving_left = false
			_player_sprite.rotation_degrees = 0
	
	if input_dir.y == -1:
		_player_sprite.flip_h = false
		_player_sprite.rotation_degrees = 270
		if _was_moving_left:
			_player_sprite.flip_v = true

	elif input_dir.y == 1:
		_player_sprite.flip_h = false
		_player_sprite.rotation_degrees = 90
		if _was_moving_left:
			_player_sprite.flip_v = true

# Updates input vector based on pressed input direction
# (prioritizes most recently pressed direction)
func _get_input() -> Vector2:
	var new_input = Vector2.ZERO
	for possible_input in _POSSIBLE_INPUT_DIRS:
		if Input.is_action_pressed(possible_input): 
			if _input_order[possible_input] == 0:
				for input in _input_order:
					if _input_order[input] != 0:
						_input_order[input] += 1
				
				_input_order[possible_input] = 1
		else: 
			_input_order[possible_input] = 0
	
	var latest_input = ""
	var latest_input_order = 0
	var is_latest_input_set = false
	for ordered_input in _input_order:
		if _input_order[ordered_input] != 0:
			if !is_latest_input_set:
				latest_input = ordered_input
				latest_input_order = _input_order[ordered_input]
				is_latest_input_set = true
			
			if _input_order[ordered_input] <= latest_input_order:
				latest_input = ordered_input
				latest_input_order = _input_order[ordered_input]
	
	match latest_input:
		"MoveLeft":
			new_input.x = -1
		"MoveRight":
			new_input.x = 1
		"MoveUp":
			new_input.y = -1
		"MoveDown":
			new_input.y = 1
	
	return new_input
	
	
# Player loses health when collision is detected from ENEMY
func lose_health() -> void:
	if _health >= Global.ENEMY_DAMAGE_DONE:
		_health = _health - Global.ENEMY_DAMAGE_DONE
	else:
		print("[END_GAME] Player is dead with ", _health, " health.")
		queue_free()
	


func set_health(delta:int):
	_health = max(_health + delta, 0)
	#TODO: signal emit game over


func set_fuel(delta:int):
	_fuel = max(_fuel + delta, 0)


## Returns current health (x) and fuel (y)
func get_stats() -> Vector2:
	return Vector2(_health, _fuel)

func get_available_interactables() -> Array:
	return available_interactables

func set_current_interactable(new_interactable: Node2D) -> void:
	current_interactable = new_interactable

func add_interactable(interactable_to_add: Node2D) -> void:
	available_interactables.append(interactable_to_add)
