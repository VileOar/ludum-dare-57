extends CharacterBody2D

# Maximum move speed of the player
const _MAX_MOVE_SPEED: float = 4 * Global.CELL_SIZE
# Player movement acceleration
const _ACCELERATION: float = 20 * Global.CELL_SIZE
# Player movement friction
const _FRICTION: float = 40 * Global.CELL_SIZE

var _input: Vector2 = Vector2.ZERO
var _input_queue: = [null]

func _physics_process(delta: float) -> void:
	_move(delta)

func _move(delta: float) -> void:
	_input = _get_input()
	if _input: 
		velocity = velocity.move_toward(_input * _MAX_MOVE_SPEED , delta * _ACCELERATION)
		if $Sprite.animation != "Mine":
				$Sprite.play("Mine")
	else: 
		velocity = velocity.move_toward(Vector2(0,0), delta * _FRICTION)
		if $Sprite.animation != "Idle":
			$Sprite.play("Idle")
	
	move_and_slide();
	
	$Sprite.flip_h = false
	$Sprite.rotation_degrees = 0
	
	if _input.x == -1:
			$Sprite.flip_h = true
	
	if _input.y == -1:
		$Sprite.rotation_degrees = 270
	elif _input.y == 1:
		$Sprite.rotation_degrees = 90

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
