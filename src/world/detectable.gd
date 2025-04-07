class_name Detectable
extends Area2D

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _particles: GPUParticles2D = $GPUParticles2D

var _type_id := Global.TileType.NONE
var _amount: int = 0

var _dying := false

# counter for how many pings
var _ping_counter := 0

var _particle_colours := {
	Global.TileType.MONEY: Color.YELLOW,
	Global.TileType.HEALTH: Color.RED,
	Global.TileType.FUEL: Color.GREEN,
}


## Setup this feature
func setup_feature(cell_type: Global.TileType):
	_type_id = cell_type


## Called by the radar to ping the tile
func ping():
	if _dying:
		return
	
	if _type_id == Global.TileType.EGG:
		_ping_counter += 1
		if _ping_counter >= Global.SCANS_BEFORE_SWARM:
			_ping_counter = 0
			Signals.spawn_burrow.emit(Global.world_map_tiles.get_random_spawn_position())
	else:
		_sprite.position = Vector2.ZERO
		_sprite.modulate = Color(Color.WHITE, 1.0)
		_sprite.show()
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(_sprite, "position", Vector2(0.0, -Global.CELL_SIZE * 0.25), 0.8)
		tween.tween_property(_sprite, "modulate", Color(Color.WHITE, 0.0), 0.4)
		tween.tween_callback(_sprite.hide)


## Called by the dig function.
## Will respond differently depending on tile type.
func mine():
	_dying = true # death process has begun
	match _type_id:
		Global.TileType.EGG:
			Signals.spawn_egg.emit(position)
			_die()
		Global.TileType.MONEY, Global.TileType.HEALTH, Global.TileType.FUEL:
			_particles.modulate = _particle_colours[_type_id]
			_particles.emitting = true


func _die():
	queue_free()


func _on_gpu_particles_2d_finished() -> void:
	if _dying:
		_die()
