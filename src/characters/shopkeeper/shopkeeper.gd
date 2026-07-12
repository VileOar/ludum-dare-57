extends Node2D
class_name Shopkeeper

var _tier: int = 0

func _init() -> void:
	add_to_group(Global.INTERACTABLE_GROUP)

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")

func set_tier(value: int) -> void:
	_tier = value

func enter_interaction() -> void:
	Global.hud_ref.show_interact_prompt("TALK")

func interact() -> void:
	Global.hud_ref.hide_interact_prompt()
	Signals.shop_open.emit(_tier)
	AudioController.play_shop_music()

func exit_interaction() -> void:
	Global.hud_ref.hide_interact_prompt()
