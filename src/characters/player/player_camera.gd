extends Camera2D

@export var look_ahead_distance := 128.0
@export var smoothing := 5.0
@export var target_smoothing := 5.0
@export var deadzone := 16.0
@export var min_speed := 64.0

var target_offset := Vector2.ZERO

func _process(delta):
	var player = get_parent()
	var velocity = player.velocity
	
	var desired_offset := Vector2.ZERO
	
	if velocity.length() > deadzone:
		var direction = velocity.normalized()
		desired_offset = direction * look_ahead_distance
	
	target_offset = target_offset.lerp(desired_offset, target_smoothing * delta)
	
	var to_target = target_offset - offset
	
	if to_target.length() < min_speed * delta:
		offset = target_offset
	else:
		offset = offset.lerp(target_offset, smoothing * delta)
