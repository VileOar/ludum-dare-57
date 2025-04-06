extends Node2D

@onready var _radar_pulse: AudioStreamPlayer = $RadarPulse
@onready var _squeak1: AudioStreamPlayer = $Squeak1 
@onready var _squeak2: AudioStreamPlayer = $Squeak2 
@onready var _squeak3: AudioStreamPlayer = $Squeak3
@onready var _music: AudioStreamPlayer = $Music
var _squeaks: Array[AudioStreamPlayer] = []

func _ready() -> void:
	_squeaks = [_squeak1, _squeak2, _squeak3]
	play_music()

func play_music() -> void:
	_music.play()

# podem usar isto para quando o player levar damage
func play_squeak(random_pitch: bool = true) -> void:
	var squeak = _squeaks.pick_random()
	if random_pitch:
		squeak.pitch_scale = randf_range(0.75, 1.5)
		squeak.play()

func play_radar_pulse() -> void:
	_radar_pulse.play()
	#play_squeak()
