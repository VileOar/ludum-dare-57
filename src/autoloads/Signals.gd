## autoload for global signals
extends Node
@warning_ignore_start("unused_signal")

## Sent when the map finishes loading
signal map_stable

## Sent when an egg is uncovered (order to spawn and enemy egg)
signal spawn_egg(pos)

## sent when a game stat is altered
signal upgrade_selected(type, cost:int, text, button_ref)

signal currency_changed(value:int)

signal health_changed(value:int)

signal fuel_changed(value:int)

signal change_shop_visibility(visible:bool)
