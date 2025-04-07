extends Control

@export var _play_scene: PackedScene


func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(_play_scene)


func _on_options_pressed() -> void:
	pass # TODO:

func _on_quit_pressed() -> void:
	get_tree().quit()
