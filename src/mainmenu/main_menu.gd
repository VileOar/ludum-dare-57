extends Control

@onready var _main_menu = $MainMenu

func _on_play_pressed() -> void:
	Global.deferred_change_scene(Global.level_scene)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	_main_menu.hide()
	$Credits.visible = true


func _on_back_pressed() -> void:
	$Credits.visible = false
	_main_menu.show()


func _on_how_to_pressed() -> void:
	_main_menu.hide()
	$HowTo.visible = true


func _on_back_how_to_pressed() -> void:
	$HowTo.visible = false
	_main_menu.show()
