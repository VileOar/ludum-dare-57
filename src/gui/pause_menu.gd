class_name PauseMenu
extends Control

@onready var _options_bg = $Options
@onready var _options = $Options/OptionsMenu

func _ready() -> void:
	Signals.options_close.connect(_on_options_close)
	# ensure default visibility
	self.show()
	_options.hide()
	_options_bg.hide()

func _on_resume_pressed() -> void:
	Signals.pause_close.emit()

func _on_options_pressed() -> void:
	_options.show()
	_options_bg.show()

func _on_quit_pressed() -> void:
	Signals.pause_close.emit()
	Global.deferred_change_scene(Global.main_menu_scene)

func _on_options_close() -> void:
	_options_bg.hide()

func can_be_closed() -> bool:
	if _options.visible:
		return false
	if _options_bg.visible:
		return false
	return true
