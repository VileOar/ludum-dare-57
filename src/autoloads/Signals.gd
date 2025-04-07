## autoload for global signals
extends Node
@warning_ignore_start("unused_signal")

## Sent when the map finishes loading
signal map_stable

## Sent when an egg is uncovered (order to spawn and enemy egg)
signal spawn_egg(pos)

## Sent when an undug egg received one too many pings so calls a random swarm event
signal spawn_burrow(pos)

## sent when a game stat is altered
signal upgrade_selected(type, cost:int, text, button_ref)

signal currency_changed(value:int)

signal health_changed(value:int)

signal fuel_changed(value:int)

signal change_shop_visibility(visible:bool)

signal end_condition(win:bool)

# send enemies
signal collect_items(item_type: int, amount: int)
