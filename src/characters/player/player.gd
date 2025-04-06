extends CharacterBody2D

# Maximum move speed of the player
const _MAX_MOVE_SPEED: float = 4 * Global.CELL_SIZE
# Player movement acceleration
const _ACCELERATION: float = 20 * Global.CELL_SIZE
# Player movement friction
const _FRICTION: float = 40 * Global.CELL_SIZE

var _health : int = Global.PLAYER_HEALTH
# Movement
var _was_moving_left: bool = false
var _input: Vector2 = Vector2.ZERO
var _input_queue: = [null]

@onready var _player_sprite: AnimatedSprite2D = $Sprite 

func _physics_process(delta: float) -> void:
	_move(delta)

func _move(delta: float) -> void:
	_input = _get_input()
	if _input: 
		velocity = velocity.move_toward(_input * _MAX_MOVE_SPEED , delta * _ACCELERATION)
		if _player_sprite.animation != "Mine":
				_player_sprite.play("Mine")
	else: 
		velocity = velocity.move_toward(Vector2(0,0), delta * _FRICTION)
		if _player_sprite.animation != "Idle":
			_player_sprite.play("Idle")
	
	move_and_slide();
	
	if _input.x == -1:
			_player_sprite.flip_h = true
			_player_sprite.flip_v = false
			_was_moving_left = true
			_player_sprite.rotation_degrees = 0
	elif _input.x == 1:
			_player_sprite.flip_h = false
			_player_sprite.flip_v = false
			_was_moving_left = false
			_player_sprite.rotation_degrees = 0
	
	if _input.y == -1:
		_player_sprite.flip_h = false
		_player_sprite.rotation_degrees = 270
		if _was_moving_left:
			_player_sprite.flip_v = true

	elif _input.y == 1:
		_player_sprite.flip_h = false
		_player_sprite.rotation_degrees = 90
		if _was_moving_left:
			_player_sprite.flip_v = true

func _get_input() -> Vector2:
	_input = Vector2.ZERO
	for input in ["MoveLeft", "MoveRight", "MoveUp", "MoveDown"]:
		if Input.is_action_just_pressed(input): 
			_input_queue.push_back(input)
		if Input.is_action_just_released(input): 
			_input_queue.erase(input)
	
	match _input_queue.back():
		"MoveLeft":
			_input.x = -1
		"MoveRight":
			_input.x = 1
		"MoveUp":
			_input.y = -1
		"MoveDown":
			_input.y = 1
	
	return _input
	
	
# Player loses health when collision is detected from ENEMY
func lose_health() -> void:
	if _health >= Global.DAMAGE_DONE:
		_health = _health - Global.DAMAGE_DONE
	else:
		print("[END_GAME] Player is dead with ", _health, " health.")
		queue_free()
