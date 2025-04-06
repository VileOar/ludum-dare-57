## autoload for global signals
extends Node

## sent when a game stat is altered
@warning_ignore("unused_signal")
signal upgrade_selected(type, cost:int, text, button_ref)

@warning_ignore("unused_signal")
signal currency_changed(value:int)

@warning_ignore("unused_signal")
signal health_changed(value:int)

@warning_ignore("unused_signal")
signal fuel_changed(value:int)

@warning_ignore("unused_signal")
signal change_shop_visibility(visible:bool)