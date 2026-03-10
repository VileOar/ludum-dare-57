extends Control

@onready var _main_menu = $TitleMenu
@onready var _credits = $Credits
@onready var _how_to = $HowTo

func _ready() -> void:
	# ensure default visibility
	_main_menu.show()
	_credits.hide()
	_how_to.hide()

func _on_play_pressed() -> void:
	Global.deferred_change_scene(Global.level_scene)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_credits_pressed() -> void:
	_main_menu.hide()
	_credits.show()

func _on_credits_back_pressed() -> void:
	_credits.hide()
	_main_menu.show()

func _on_how_to_pressed() -> void:
	_main_menu.hide()
	_how_to.show()

func _on_how_to_back_pressed() -> void:
	_how_to.hide()
	_main_menu.show()
