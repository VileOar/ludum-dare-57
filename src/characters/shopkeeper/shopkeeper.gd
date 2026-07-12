extends Node2D

func _init() -> void:
	add_to_group(Global.INTERACTABLE_GROUP)

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")

func enter_interaction() -> void:
	Global.hud_ref.show_interact_prompt("TALK")

func interact() -> void:
	Global.hud_ref.hide_interact_prompt()
	Signals.change_shop_visibility.emit(true)
	Signals.shop_open.emit()
	AudioController.play_shop_music()

func exit_interaction() -> void:
	Global.hud_ref.hide_interact_prompt()
