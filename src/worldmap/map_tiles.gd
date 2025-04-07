class_name MapTiles
extends TileMapLayer


@export var feature_scene: PackedScene

@onready var feature_holder: Node2D = $FeatureHolder

var _cell_features: Dictionary[Vector2i, Detectable]


## Register a feature in the dictionary to be retrieved later.
func save_feature(cell_pos: Vector2i, cell_type: int):
	var feature = feature_scene.instantiate() as Detectable
	feature.position = map_to_local(cell_pos)
	feature.setup_feature(cell_type)
	feature_holder.add_child.call_deferred(feature)
	_cell_features[cell_pos] = feature


## Try to dig a given position.[br]
## Returns true if a feature existed here.
func try_dig_feature(cell_pos: Vector2i) -> bool:
	var feature := _cell_features.get(cell_pos, null) as Detectable
	if feature == null:
		return false
	feature.mine()
	# remove and delete the feature
	_cell_features.erase(cell_pos)
	# NOTE: feature nodes are responsible for destroying themselves
	return true


# TODO: remove
# Store cells which have a feature in them (those that don't, will not show up here)
var _cell_data: Dictionary


func save_cell_data(cell_pos: Vector2i, cell_data: int):
	_cell_data[cell_pos] = cell_data


func get_cell_data(cell_pos: Vector2i) -> int:
	return _cell_data.get(cell_pos, Global.TileType.NONE)

# adapted from https://www.reddit.com/r/godot/comments/sdypwa/how_to_modulate_specific_tiles_in_a_tilemap/

# Ignore all of this

#var _standby_fn: Dictionary = {}
#var _update_fn: Dictionary = {} # Dictionary of Callable
#
#
#func update_tile(coords: Vector2i, fn: Callable):
	#_standby_fn[coords] = fn
#
#
#func force_update_tiles():
	#_update_fn = _standby_fn.duplicate()
	#notify_runtime_tile_data_update()
#
#
#func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	#return _update_fn.has(coords)
#
#
#func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	#if not _update_fn.has(coords): return
	#_update_fn[coords].call(tile_data)
	#_update_fn.erase(coords)
