class_name LoadingScreen
extends Control


@onready var _loading_bar: ProgressBar = %LoadingBar


func _ready() -> void:
	Signals.map_stable.connect(_on_map_generated)


func _process(_delta: float) -> void:
	if Global.world_map_tiles:
		_loading_bar.value = Global.world_map_tiles.load_percent


func _on_map_generated():
	hide()
