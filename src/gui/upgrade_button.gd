extends Button
class_name UpgradeButton

@export var description : String
@export var cost := 10
@export var type : Global.Upgrades


func _ready():
	disabled = (Global._current_upgrades[type] == 1)


func _on_pressed():
	Signals.upgrade_selected.emit(type, cost, description, self)
