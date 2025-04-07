# THIS NODE EXISTS TO HAVE PROCESS MODE SET TO ALWAYS
extends Node

const FADE_DURATION = 0.5
const END_LAG = 1.0

@onready var _fade_rect: ColorRect = %EndGameFade


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Signals.end_condition.connect(_end_game)


func _end_game(state):
    Global.end_state = state
    get_tree().paused = true
    #AudioManager.stop_audio("Music1")
    await get_tree().create_timer(END_LAG).timeout
    var tween = create_tween()
    _fade_rect.modulate = Color(Color.BLACK, 0)
    tween.tween_property(_fade_rect, "modulate", Color(Color.WHITE, 1), FADE_DURATION)
    await tween.finished
    get_tree().paused = false
    get_tree().change_scene_to_file("res://src/gui/EndMenu.tscn")