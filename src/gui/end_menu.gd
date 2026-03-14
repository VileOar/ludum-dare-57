extends Control

@onready var status_label: Label = %StatusLabel

func _ready():
	if Global.end_state:
		status_label.text = "You made it!"
	else:
		status_label.text = "You didn't make it..."

func _on_back_pressed() -> void:
	Global.deferred_change_scene(Global.main_menu_scene)
