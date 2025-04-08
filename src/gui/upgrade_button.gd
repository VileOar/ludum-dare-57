extends Button
class_name UpgradeButton

@export var description : String
@export var cost := 1
@export var type : Global.Upgrades


func _on_pressed():
	var real_cost = Global.get_cost_from_tier(cost)
	Signals.upgrade_selected.emit(type, real_cost, description, self)
