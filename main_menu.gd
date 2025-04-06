extends Control

const PLAY_SCENE: String = "res://levels/main_level.tscn"
var new_scene: Node = null

func _on_play_pressed() -> void:
	$MenuMarginContainer.hide()
	$LoadingMarginContainer.show()
	new_scene = load(PLAY_SCENE).instantiate()
	get_tree().root.add_child(new_scene)
	new_scene.visible = false
	
func _process(delta: float) -> void:
	if Global.world_map_tiles:
		$LoadingMarginContainer/VBoxContainer/ProgressBar.value = Global.world_map_tiles.load_percent
		if Global.world_map_tiles.are_tiles_generated and new_scene:
			var current = get_tree().current_scene
			if current:
				current.queue_free()
			get_tree().current_scene = new_scene
			new_scene.visible = true
			new_scene = null

func _on_options_pressed() -> void:
	pass # todo

func _on_quit_pressed() -> void:
	get_tree().quit()
