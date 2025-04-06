extends Control

const PLAY_SCENE: String = "res://levels/main_level.tscn"

@onready var _menu_margin_container: MarginContainer = %MenuMarginContainer
@onready var _loading_margin_container: MarginContainer = %LoadingMarginContainer
@onready var _loading_bar: ProgressBar = $LoadingMarginContainer/VBoxContainer/LoadingBar

var new_scene: Node = null

func _on_play_pressed() -> void:
	_menu_margin_container.hide()
	_loading_margin_container.show()
	new_scene = load(PLAY_SCENE).instantiate()
	get_tree().root.add_child(new_scene)
	new_scene.visible = false
	
func _process(delta: float) -> void:
	if Global.world_map_tiles:
		_loading_bar.value = Global.world_map_tiles.load_percent
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
