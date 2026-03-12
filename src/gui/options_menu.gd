extends Control

func _on_options_back_pressed() -> void:
	self.hide()
	Signals.options_close.emit()
