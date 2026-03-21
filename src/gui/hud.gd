extends Control
class_name Hud

const _MAX_HEALTH_BAR_SIZE: int = 700
const _MAX_STAMINA_BAR_SIZE: int = 450

var _tex_health_up1: Texture2D = load("res://assets/gui/upgrades/health-up-1.png")
var _tex_health_up2: Texture2D = load("res://assets/gui/upgrades/health-up-2.png")
var _tex_health_up3: Texture2D = load("res://assets/gui/upgrades/health-up-3.png")

var _tex_stamina_up1: Texture2D = load("res://assets/gui/upgrades/stamina-up-1.png")
var _tex_stamina_up2: Texture2D = load("res://assets/gui/upgrades/stamina-up-2.png")
var _tex_stamina_up3: Texture2D = load("res://assets/gui/upgrades/stamina-up-3.png")

var _tex_dig_up1: Texture2D = load("res://assets/gui/upgrades/claws-up-1.png")
var _tex_dig_up2: Texture2D = load("res://assets/gui/upgrades/claws-up-2.png")
var _tex_dig_up3: Texture2D = load("res://assets/gui/upgrades/claws-up-3.png")

var _tex_scan_up1: Texture2D = load("res://assets/gui/upgrades/radar-up-1.png")
var _tex_scan_up2: Texture2D = load("res://assets/gui/upgrades/radar-up-2.png")
var _tex_scan_up3: Texture2D = load("res://assets/gui/upgrades/radar-up-3.png")

@onready var _health_bar: ProgressBar = %HealthBar
@onready var _stamina_bar: ProgressBar = %StaminaBar

@onready var _health_hbox: HBoxContainer = %HealthHBox
@onready var _stamina_hbox: HBoxContainer = %StaminaHBox

@onready var _currency_label: Label = %CurrencyLabel
@onready var _upgrades: HBoxContainer = %UpgradesHBox

@onready var _tr_dig: TextureRect = %DigUpg
@onready var _tr_health: TextureRect = %HealthUpg
@onready var _tr_scan: TextureRect = %ScanUpg
@onready var _tr_stamina: TextureRect = %StaminaUpg
@onready var _upg_order: Array[TextureRect] = [_tr_dig, _tr_scan, _tr_health, _tr_stamina]

func _ready() -> void:
	Global.hud_ref = self
	update_health_bar(Global.max_health)
	update_stamina_bar(Global.max_fuel)
	update_currency_label(Global.get_currency())

func update_health_bar(new_health: int) -> void:
	_health_hbox.size.x = (float(Global.max_health) / float(Global.HEALTH_UPGRADE_3)) * _MAX_HEALTH_BAR_SIZE
	@warning_ignore("integer_division")
	_health_bar.value = new_health * 100 / Global.max_health

func update_stamina_bar(new_stamina: int) -> void:
	_stamina_hbox.size.x = (float(Global.max_fuel) / float(Global.FUEL_UPGRADE_3)) * _MAX_STAMINA_BAR_SIZE
	@warning_ignore("integer_division")
	_stamina_bar.value = new_stamina * 100 / Global.max_fuel

func update_currency_label(new_currency: int) -> void:
	_currency_label.text = str(new_currency)

func add_upgrade(upgrade: Global.Upgrades) -> void:
	match upgrade:
		Global.Upgrades.HEALTH_1:
			_upgrade_health(_tex_health_up1) 
		Global.Upgrades.HEALTH_2:
			_upgrade_health(_tex_health_up2) 
		Global.Upgrades.HEALTH_3:
			_upgrade_health(_tex_health_up3)
		Global.Upgrades.FUEL_1:
			_upgrade_stamina(_tex_stamina_up1)
		Global.Upgrades.FUEL_2:
			_upgrade_stamina(_tex_stamina_up2)
		Global.Upgrades.FUEL_3:
			_upgrade_stamina(_tex_stamina_up3)
		Global.Upgrades.DRILL_1:
			_upgrade_dig(_tex_dig_up1)
		Global.Upgrades.DRILL_2:
			_upgrade_dig(_tex_dig_up2)
		Global.Upgrades.DRILL_3:
			_upgrade_dig(_tex_dig_up3)
		Global.Upgrades.SCANNER_1:
			_upgrade_scan(_tex_scan_up1)
		Global.Upgrades.SCANNER_2:
			_upgrade_scan(_tex_scan_up2)
		Global.Upgrades.SCANNER_3:
			_upgrade_scan(_tex_scan_up3)

func _upgrade_health(tex: Texture2D) -> void:
	_tr_health.texture = tex
	_order_upgrades()

func _upgrade_stamina(tex: Texture2D) -> void:
	_tr_stamina.texture = tex
	_order_upgrades()

func _upgrade_dig(tex: Texture2D) -> void:
	_tr_dig.texture = tex
	_order_upgrades()

func _upgrade_scan(tex: Texture2D) -> void:
	_tr_scan.texture = tex
	_order_upgrades()

func _order_upgrades():
	for i in range(_upg_order.size()):
		if _upg_order[i]:
			_upgrades.move_child(_upg_order[i], i + 1)
