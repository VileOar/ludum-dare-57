class_name Detectable
extends Area2D

@onready var _sprite: Sprite2D = $Sprite2D

var _type_id := Global.TileType.NONE


## Setup this feature
func setup_feature(cell_type: Global.TileType):
	_type_id = cell_type


## Called by the radar to ping the tile
func ping():
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
# TODO: move the enemy spawn code here
func mine():
	match _type_id:
		Global.TileType.EGG:
			Signals.spawn_egg.emit(position)


# Function that briefly reveals this tile.
# TODO: have a tween that moves the sprite 2d up (with ease out) and slowly makes it fade away (opacity)
# NOTE: the sprite should NOT be the same as its tile type, just a '?' or something
func _reveal():
	pass
