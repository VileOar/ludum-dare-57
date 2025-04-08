extends Control
# Very bad code, caution and sorry

@onready var _description_label: Label = %Description
@onready var _cost_label: Label = %CostValue
@onready var _buy_button: Button = %BuyButton
@onready var _money_label: Label = %MoneyValue
@onready var _health_label: Label = %HealthValue
@onready var _fuel_label: Label = %FuelValue
@onready var _sell_button: Button = %SellButton

const REFUEL_MULTIPLIER := 2
const REPAIR_MULTIPLIER := 2
const ZERO_STRING := "--"

var _current_cost := 0
var _current_upgrade_selected : Global.Upgrades
var _current_btn : Node

var _upgrade_selected := false
var _viable_action := false
var _refuel := false
var _repair := false


func _ready():
	Signals.change_shop_visibility.connect(_toggle_visibility)
	Signals.upgrade_selected.connect(_on_upgrade_selected)
	Signals.currency_changed.connect(_set_money_label)
	Signals.health_changed.connect(_set_health_label)
	Signals.fuel_changed.connect(_set_fuel_label)
	

func _toggle_visibility(value:bool):
	visible = value
	if value:
		_set_money_label(Global.get_currency())
		_set_health_label(int(Global.player_ref.get_stats().x))
		_set_fuel_label(int(Global.player_ref.get_stats().y))

		_current_cost = 0
		_current_btn = null
		_upgrade_selected = false
		_viable_action = false

		_reset_cost_and_description()

		refresh_sell_button()
		_refresh_buy_button_state()


func _reset_cost_and_description():
	_description_label.text = "Welcome to the shop!"
	_cost_label.text = ZERO_STRING


func _set_money_label(new_value: int):
	_money_label.text = str(new_value)


func _set_health_label(new_value: int):
	_health_label.text = str(new_value)


func _set_fuel_label(new_value: int):
	_fuel_label.text = str(new_value)


func _refresh_buy_button_state():
	if _viable_action:
		_buy_button.disabled = !(Global.get_currency() >= _current_cost)
	else:
		if _current_btn == null:
			_buy_button.disabled = true
			return
		else:
			_buy_button.disabled = !(Global.get_currency() >= _current_cost)


func refresh_sell_button():
	#TODO:
	#_sell_button.true = Global.player_ref.has_loot

	_sell_button.disabled = true


func _manage_button_selection(cost, description, refuel, repair):
	_description_label.text = description

	_refuel = refuel
	_repair = repair

	if cost > 0:
		_cost_label.text = str(cost)
	else:
		_cost_label.text = ZERO_STRING

	_current_cost = cost

	_refresh_buy_button_state()


# || --- Signals --- ||

func _on_upgrade_selected(type, cost, text, btn_ref):
	_current_btn = btn_ref
	_upgrade_selected = true
	_viable_action = false
	_current_upgrade_selected = type

	_manage_button_selection(cost, text, false, false)


func _on_buy_button_pressed():
	if _upgrade_selected:
		Global.add_upgrade(_current_upgrade_selected)
		if _current_btn != null:
			_current_btn.disabled = true;
			_current_btn = null

	_viable_action = false
	Global.set_currency(-_current_cost)

	if _refuel:
		_refuel = false
		Global.player_ref.set_fuel(Global.max_fuel-int(Global.player_ref.get_stats().y))
		@warning_ignore("narrowing_conversion")
		Global.hud_ref.update_stamina_bar(Global.player_ref.get_stats().y)

	if _repair:
		_repair = false
		Global.player_ref.set_health(Global.max_health-int(Global.player_ref.get_stats().x))
		@warning_ignore("narrowing_conversion")
		Global.hud_ref.update_health_bar(Global.player_ref.get_stats().x)

	_refresh_buy_button_state()
	_reset_cost_and_description()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("CloseShop"):
		_on_exit_button_pressed() 

func _on_exit_button_pressed():
	AudioController.play_music()
	_toggle_visibility(false)


func _on_sell_button_pressed():
	_upgrade_selected = false
	_viable_action = false
	_current_btn = null

	# TODO: Global.player_ref.get_loot actually sell
	_refresh_buy_button_state()
	refresh_sell_button()


func _on_refuel_button_pressed():
	_viable_action = false

	var dif = Global.max_fuel - Global.player_ref.get_stats().y
	var temp_cost : int = dif * REFUEL_MULTIPLIER

	if (dif > 0) and (Global.get_currency() >= temp_cost):
		_viable_action = true
		
	_upgrade_selected = false
	_current_btn = null
	_manage_button_selection(temp_cost, "Restore stamina to full", true, false)
	

func _on_repair_button_pressed():
	_viable_action = false
	var dif = Global.max_health - Global.player_ref.get_stats().x
	var temp_cost : int = dif * REPAIR_MULTIPLIER
	
	if (dif > 0) and (Global.get_currency() >= temp_cost):
		_viable_action = true
	
	_upgrade_selected = false
	_current_btn = null
	_manage_button_selection(temp_cost, "Restore health to full", false, true)
