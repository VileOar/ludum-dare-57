extends CharacterBody2D

# Maximum move speed of the player
const _MAX_MOVE_SPEED: float = 4 * Global.CELL_SIZE
# Player movement acceleration
const _ACCELERATION: float = 20 * Global.CELL_SIZE
# Player movement friction
const _FRICTION: float = 40 * Global.CELL_SIZE

# Stores last movement direction on x axis
var _was_moving_left: bool = false
# Stores current input direction
var _current_input: Vector2 = Vector2.ZERO
# Stores currently pressed movement inputs
var _input_queue: = [null]

@onready var _player_sprite: AnimatedSprite2D = $Sprite 
@onready var _mining_check_ray: RayCast2D = $MiningCheckRay

func _unhandled_input(_event: InputEvent) -> void:
	_current_input = _get_input()

func _physics_process(delta: float) -> void:
	_move(_current_input, delta)
	_try_to_mine(_current_input)

func _process(_delta: float) -> void:
	_update_sprite(_current_input)

# Updates player velocity based on the input direction
func _move(input_dir: Vector2, delta: float) -> void:
	if input_dir: 
		velocity = velocity.move_toward(input_dir * _MAX_MOVE_SPEED , delta * _ACCELERATION)
	else: 
		velocity = velocity.move_toward(Vector2(0,0), delta * _FRICTION)
	
	move_and_slide();

# Update ray cast position to face movement direction and try to mine in that direction
func _try_to_mine(input_dir: Vector2) -> void:
	_mining_check_ray.target_position = input_dir * Global.CELL_SIZE
	if _mining_check_ray.is_colliding() and Global.world_map_tiles:
		Global.world_map_tiles.try_dig_tile(to_global(_mining_check_ray.target_position), 3)

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
	for input in ["MoveLeft", "MoveRight", "MoveUp", "MoveDown"]:
		if Input.is_action_just_pressed(input): 
			_input_queue.push_back(input)
		if Input.is_action_just_released(input): 
			_input_queue.erase(input)
	
	match _input_queue.back():
		"MoveLeft":
			new_input.x = -1
		"MoveRight":
			new_input.x = 1
		"MoveUp":
			new_input.y = -1
		"MoveDown":
			new_input.y = 1
	
	return new_input
