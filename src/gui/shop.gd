extends Control

@onready var _description_label: Label = %Description
@onready var _cost_label: Label = %CostValue


func _ready():
	Signals.upgrade_selected.connect(_on_upgrade_selected)

func _on_upgrade_selected(type, cost, text2):
	_description_label.text = text2
	print(text2)
	_cost_label.text = str(cost)
