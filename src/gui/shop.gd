extends Control

@onready var _description_label: Label = %Description
@onready var _cost_label: Label = %CostValue
@onready var _buy_button: Button = %BuyButton
@onready var _money_label: Label = %MoneyValue
@onready var _health_label: Label = %HealthValue
@onready var _fuel_label: Label = %FuelValue

var _current_cost := 0
var _current_upgrade_selected : Global.Upgrades
var _current_btn : Node

var _upgrade_selected := false
var _viable_action := false


func _ready():
	Signals.upgrade_selected.connect(_on_upgrade_selected)
	Signals.currency_changed.connect(_set_money_label)
	Signals.change_shop_visibility.connect(_toggle_visibility)

	_set_money_label(Global.get_currency())
	_set_health_label(Global.player_ref.get_stats().x)
	_set_fuel_label(Global.player_ref.get_stats().y)


func _toggle_visibility(value:bool):
	visible = value


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

	
func _manage_button_selection(cost, description):
	_description_label.text = description
	_cost_label.text = str(cost)

	_current_cost = cost

	_refresh_buy_button_state()


# || --- Signals --- ||

func _on_upgrade_selected(type, cost, text, btn_ref):
	_manage_button_selection(cost, text)
	_current_btn = btn_ref
	_upgrade_selected = true
	_viable_action = false
	_current_upgrade_selected = type


func _on_buy_button_pressed():
	if _upgrade_selected:
		Global.add_upgrade(_current_upgrade_selected)
		if _current_btn != null:
			_current_btn.disabled = true;
			_current_btn = null

	Global.set_currency(-_current_cost)
	_refresh_buy_button_state()


func _on_exit_button_pressed():
	_toggle_visibility(false)


# TODO: WIP
func _on_refuel_button_pressed():
	_manage_button_selection(1, "refuel")
	_upgrade_selected = false
	_current_btn = null
	_viable_action = true
	_refresh_buy_button_state()
	

func _on_repair_button_pressed():
	_manage_button_selection(2, "repair")
	_upgrade_selected = false
	_current_btn = null
	_viable_action = true
	_refresh_buy_button_state()


func _on_sell_button_pressed():
	_manage_button_selection(3, "sell")
	_upgrade_selected = false
	_viable_action = true
	_current_btn = null
	_refresh_buy_button_state()
