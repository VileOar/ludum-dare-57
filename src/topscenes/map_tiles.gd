class_name MapTiles
extends TileMapLayer

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
