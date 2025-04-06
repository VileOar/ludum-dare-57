extends Button
class_name UpgradeButton

@export var description : String
@export var cost := 10
#@export var type : UpgradeEnum


func _on_pressed():
	Signals.upgrade_selected.emit(0, cost, description)
