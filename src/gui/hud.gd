extends Control
class_name Hud

@onready var _health_bar: ProgressBar = $HealthBar
@onready var _stamina_bar: ProgressBar = $HealthBar

func _ready() -> void:
	Global.hud_ref = self
	update_health(Global.max_health)
	update_stamina(Global.max_fuel)

func update_health(new_health: int) ->void:
	_health_bar.value = new_health * 100 / Global.max_health

func update_stamina(new_stamina: int) ->void:
	_stamina_bar.value = new_stamina * 100 / Global.max_fuel
