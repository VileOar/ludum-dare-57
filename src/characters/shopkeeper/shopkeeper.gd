extends Node2D

@onready var _interact_ui: Control = $InteractPrompt

func _init() -> void:
	add_to_group(Global.INTERACTABLE_GROUP)

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")

func enter_interaction() -> void:
	_interact_ui.visible = true
	_interact_ui.play_animation()

func interact() -> void:
	Signals.change_shop_visibility.emit(true)

func exit_interaction() -> void:
	_interact_ui.visible = false
	_interact_ui.stop_animation()	
