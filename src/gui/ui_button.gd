extends Button

func _on_pressed() -> void:
	AudioController.play_click()

func _on_mouse_entered() -> void:
	AudioController.play_hover()
