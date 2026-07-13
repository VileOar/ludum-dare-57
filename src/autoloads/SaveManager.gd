extends Node

const SAVE_PATH := "user://save.json"

var save_data: Dictionary = {}

var _dirty: bool = false

func _ready() -> void:
	load_game()
	Signals.map_stable.connect(_on_map_stable)


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
	
	save_data.clear()


func mark_dirty() -> void:
	_dirty = true


func save_map() -> void:
	if Global.world_map_tiles_ref == null:
		return
	
	# Update the save dictionary
	save_data["master_seed"] = Global.world_map_tiles_ref.master_seed
	
	var serialized_dug_tiles := []
	
	for cell in Global.world_map_tiles_ref.dug_tiles.keys():
		serialized_dug_tiles.append([cell.x, cell.y])
	
	save_data["dug_tiles"] = serialized_dug_tiles


func write_save_file()-> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file == null:
		return
	
	file.store_string(JSON.stringify(save_data))


func save_player() -> void:
	if Global.player_ref == null:
		return
	
	var pos := Global.player_ref.global_position
	save_data["player_pos"] = [pos.x, pos.y]


func load_game() -> bool:
	if !has_save():
		save_data.clear()
		return false
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if file == null:
		save_data.clear()
		return false
	
	var parsed = JSON.parse_string(file.get_as_text())
	
	if parsed == null:
		save_data.clear()
		return false
	
	save_data = parsed
	return true


func load_or_generate_map() -> void:
	if save_data.has("master_seed"):
		Global.world_map_tiles_ref.generate_tiles(save_data["master_seed"])
	else:
		Global.world_map_tiles_ref.generate_tiles()


func _on_autosave_timer_timeout() -> void:
	save_player()
	
	if _dirty:
		save_map()
		_dirty = false
	
	write_save_file()


func _on_map_stable():
	if save_data.has("dug_tiles"):
		Global.world_map_tiles_ref.load_dug_tiles(save_data["dug_tiles"])
	
	if save_data.has("player_pos"):
		var pos = save_data["player_pos"]
		Global.player_ref.global_position = Vector2(pos[0], pos[1])
