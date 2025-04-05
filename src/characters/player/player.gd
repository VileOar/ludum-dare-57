extends CharacterBody2D

# Size of game units in pixels (128x128)
const TILE_SIZE: int = 128
const MOVE_SPEED: float = 3 * TILE_SIZE
const _TWEEN_SPEED: float = 2

var _is_moving: bool = false

var _directions: Dictionary = {
	"MoveRight": Vector2.RIGHT,
	"MoveLeft": Vector2.LEFT,
	"MoveUp": Vector2.UP,
	"MoveDown": Vector2.DOWN
}

@onready var _move_check_ray = $MoveCheckRay

func _ready() -> void:
	position = position.snapped(Vector2.ONE * TILE_SIZE) + Vector2.ONE * TILE_SIZE / 2

func _process(delta: float) -> void:
	if !_is_moving and !$Sprite.animation == "Idle":
		$Sprite.play("Idle")

func _unhandled_input(event: InputEvent) -> void:
	if _is_moving:
		return
	for direction in _directions.keys():
		if event.is_action(direction):
			print("input detected")
			_move(direction)
			$Sprite.flip_h = false
			$Sprite.rotation_degrees = 0
			match direction:
				"MoveRight":
					return
				"MoveLeft":
					$Sprite.flip_h = true
					return
				"MoveUp":
					$Sprite.rotation_degrees = 270
					return
				"MoveDown":
					$Sprite.rotation_degrees = 90
					return

func _move(move_direction: String) -> void:
	_move_check_ray.target_position = _directions[move_direction] * TILE_SIZE
	_move_check_ray.force_raycast_update()
	
	if !_move_check_ray.is_colliding():
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", position + _directions[move_direction] * TILE_SIZE,
		1.0/_TWEEN_SPEED).set_trans(Tween.TRANS_SINE)
		_is_moving = true
		if !$Sprite.animation == "Mine":
			$Sprite.play("Mine")
		await tween.finished
		_is_moving = false
