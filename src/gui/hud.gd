extends Control
class_name Hud

@onready var _health_bar: ProgressBar = $HealthBar
@onready var _stamina_bar: ProgressBar = $StaminaBar
@onready var _currency_label: Label = $CurrencyLabel

func _ready() -> void:
	Global.hud_ref = self
	update_health_bar(Global.max_health)
	update_stamina_bar(Global.max_fuel)
	update_currency_label(Global.get_currency())

func update_health_bar(new_health: int) -> void:
	@warning_ignore("integer_division")
	_health_bar.value = new_health * 100 / Global.max_health

func update_stamina_bar(new_stamina: int) -> void:
	@warning_ignore("integer_division")
	_stamina_bar.value = new_stamina * 100 / Global.max_fuel

func update_currency_label(new_currency: int) -> void:
	_currency_label.text = str(new_currency)
