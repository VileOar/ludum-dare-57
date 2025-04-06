## autoload for global signals
extends Node

## sent when a game stat is altered
@warning_ignore("unused_signal")
signal upgrade_selected(type, cost:int, text)