extends Control

@onready var _description_label: Label = %Description
@onready var _cost_label: Label = %CostValue
@onready var _buy_button: Button = %BuyButton
@onready var _money_label: Label = %MoneyValue

var _current_cost := 0
var _current_upgrade_selected : Global.Upgrades
var _current_btn : Button


func _ready():
	Signals.upgrade_selected.connect(_on_upgrade_selected)
	Signals.currency_changed.connect(_set_money_label)

	_set_money_label(Global.get_currency())


func _on_upgrade_selected(type, cost, text, btn_ref):
	_description_label.text = text
	_cost_label.text = str(cost)

	_current_cost = cost
	_current_upgrade_selected = type
	_current_btn = btn_ref

	_refresh_buy_button_state()


func _on_buy_button_pressed():
	if _current_btn != null:
		Global.add_upgrade(_current_upgrade_selected)
		_current_btn.disabled = true;
		Global.set_currency(-_current_cost)

		_current_btn = null
		_refresh_buy_button_state()


func _set_money_label(new_value: int):
	_money_label.text = str(new_value)


func _refresh_buy_button_state():
	if _current_btn == null:
		_buy_button.disabled = true
		return
	else:
		_buy_button.disabled = !(Global.get_currency() >= _current_cost)