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

# Mining
# How far from a tile the the player tries to mine
const _MINING_RANGE = int(float(Global.CELL_SIZE)/2.0)
# How long it takes to mine a tile (in seconds)
const _TIME_TO_MINE: float = 0.5

# Movement
# Stores current input direction
var _current_move_input: Vector2 = Vector2.ZERO
# Stores a priority value for each input (lower = higher priority)
var _input_order: Dictionary = {
"MoveLeft" = 0, 
"MoveRight" = 0, 
"MoveUp" = 0, 
"MoveDown" = 0}

# The player's current health (initialized on _ready)
var _health: int
# The player's current fuel (initialized on _ready)
var _fuel: int
# The player's current mining strength
var _mining_strength: int = 0

# Stores how long the player has been trying to mine a tile (updated by _try_to_mine)
var _time_trying_to_mine: float = 0
# Stores the direction the player is currently trying to mine in
var _current_mining_direction: Vector2 = Vector2.ZERO

var available_interactables: Array = []
var current_interactable = null 

@onready var _player_sprite: AnimatedSprite2D = $Sprite 
@onready var _mining_check_ray: RayCast2D = $MiningCheckRay
@onready var _radar_pulse: RadarPulse = $RadarPulse

var can_play = false

func _ready() -> void:
	Global.player_ref = self
	
	# Initialize player variables
	_health = Global.max_health
	_fuel = Global.max_fuel
	
	# wait while the map has not yet loaded
	var busy = true
	while busy:
		if Global.world_map_tiles and Global.world_map_tiles.is_stable():
			busy = false
			can_play = true
			#Global.world_map_tiles.try_dig_tile(position, Global.MAX_MINING_STRENGTH)
		else:
			await Signals.map_stable


func _input(event):
	if event.is_action_pressed("Interact") && !available_interactables.is_empty():
		current_interactable.interact()

func _unhandled_input(_event: InputEvent) -> void:
	_current_move_input = _get_movement_input()
	_check_radar_input()

func _physics_process(delta: float) -> void:
	if can_play:
		_move(_current_move_input, delta)
		_try_to_mine(_current_move_input, delta)

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
		_update_sprite(_current_move_input)

# Updates player velocity based on the input direction
func _move(input_dir: Vector2, delta: float) -> void:
	if input_dir: 
		velocity = velocity.move_toward(input_dir * _MAX_MOVE_SPEED , delta * _ACCELERATION)
	else: 
		velocity = velocity.move_toward(Vector2(0,0), delta * _FRICTION)
	
	move_and_slide();

# Update ray cast position to face movement direction and try to mine in that direction
func _try_to_mine(input_dir: Vector2, delta: float) -> void:
	_mining_check_ray.target_position = input_dir * _MINING_RANGE
	if _mining_check_ray.is_colliding() and Global.world_map_tiles:
		# Reset time trying to mine if direction changed
		if input_dir != _current_mining_direction:
			_current_mining_direction = input_dir
			_time_trying_to_mine = 0
		# Update time trying to mine
		_time_trying_to_mine += delta
		# Mine block if time trying to mine exceeds mining time
		if _time_trying_to_mine >= _TIME_TO_MINE:
			Global.world_map_tiles.try_dig_tile(
				to_global(_mining_check_ray.target_position), 
				_mining_strength)
			# Reset time trying to mine
			_time_trying_to_mine = 0
	else:
		# Reset time trying to mine
		_time_trying_to_mine = 0

# Updates sprite flip and rotation based on input vector
func _update_sprite(input_dir: Vector2) -> void:
	if input_dir:
		if _player_sprite.animation != "Mine":
			_player_sprite.play("Mine")
	else:
		if _player_sprite.animation != "Idle":
			_player_sprite.play("Idle")
	
	if input_dir.x == -1:
			_player_sprite.flip_v = false
			_player_sprite.rotation_degrees = 270
	elif input_dir.x == 1:
			_player_sprite.flip_v = false
			_player_sprite.rotation_degrees = 90
	
	if input_dir.y == -1:
		_player_sprite.rotation_degrees = 0
		_player_sprite.flip_v = false
	elif input_dir.y == 1:
		_player_sprite.rotation_degrees = 0
		_player_sprite.flip_v = true

# Updates input vector based on pressed input direction
# (prioritizes most recently pressed direction)
func _get_movement_input() -> Vector2:
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

func _check_radar_input():
	if Input.is_action_just_pressed("RadarPulse") and _fuel > 0:
		var radar_activated = _radar_pulse.activate()
		if radar_activated:
			_fuel -= 1
			Global.hud_ref.update_stamina_bar(_fuel)

# Player loses health when collision is detected from ENEMY
func lose_health() -> void:
	if _health > Global.ENEMY_DAMAGE_DONE:
		_health = _health - Global.ENEMY_DAMAGE_DONE
	else:
		print("[END_GAME] Player is dead with ", _health, " health.")
		queue_free()
	
	# Update health bar
	if Global.hud_ref:
		Global.hud_ref.update_health_bar(_health)	

func set_health(delta:int):
	_health = max(_health + delta, 0)
	Signals.health_changed.emit(_health)
	#TODO: signal emit game over
	# Update health bar
	if Global.hud_ref:
		Global.hud_ref.update_health_bar(_health)

func set_health_to_max():
	_health = Global.max_health
	# Update health bar
	if Global.hud_ref:
		Global.hud_ref.update_health_bar(_health)

func set_fuel(delta:int):
	_fuel = max(_fuel + delta, 0)
	Signals.fuel_changed.emit(_fuel)
	# Update stamina bar
	if Global.hud_ref:
		Global.hud_ref.update_stamina_bar(_fuel)

func set_fuel_to_max():
	_fuel = Global.max_fuel
	# Update stamina bar
	if Global.hud_ref:
		Global.hud_ref.update_stamina_bar(_fuel)

func set_mining_strength(new_strength: int):
	_mining_strength = new_strength

func set_radar_level(new_level: int):
	_radar_pulse.set_level(new_level)

## Returns current health (x) and fuel (y)
func get_stats() -> Vector2:
	return Vector2(_health, _fuel)

func get_available_interactables() -> Array:
	return available_interactables

func set_current_interactable(new_interactable: Node2D) -> void:
	current_interactable = new_interactable

func add_interactable(interactable_to_add: Node2D) -> void:
	available_interactables.append(interactable_to_add)
