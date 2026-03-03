extends Control

func _on_play_pressed() -> void:
	Global.deferred_change_scene(Global.level_scene)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	$Menu.visible = false
	$Credits.visible = true


func _on_back_pressed() -> void:
	$Credits.visible = false
	$Menu.visible = true


func _on_how_to_pressed() -> void:
	$Menu.visible = false
	$HowTo.visible = true


func _on_back_how_to_pressed() -> void:
	$HowTo.visible = false
	$Menu.visible = true
