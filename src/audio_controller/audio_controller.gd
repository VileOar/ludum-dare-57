extends Node2D

@onready var _music_transition: AnimationPlayer = $MusicTransition
# Music
@onready var _main_music: AudioStreamPlayer = $Music
@onready var _shop_music: AudioStreamPlayer = $ShopMusic
# SFX
@onready var _radar_pulse: AudioStreamPlayer = $RadarPulse
@onready var _claw_ricochet: AudioStreamPlayer = $ClawRicochet
@onready var _dirt_digs: Array[AudioStreamPlayer] = [$DirtDig1, $DirtDig2, $DirtDig3]
@onready var _squeaks: Array[AudioStreamPlayer] = [$Squeak1, $Squeak2, $Squeak3]
@onready var _stone_breaks: Array[AudioStreamPlayer] = [$StoneBreak1, $StoneBreak2]
# UI
@onready var _click: AudioStreamPlayer = $Click
@onready var _hover: AudioStreamPlayer = $Hover

func _ready() -> void:
	_start_music()

func _get_random_pitch() -> float:
	return randf_range(0.9, 1.2)

func _start_music() -> void:
	_main_music.play()
	_shop_music.play()
	_shop_music.volume_db = -80

func play_music() -> void:
	_music_transition.play("ChangeToMainMusic")

func play_shop_music() -> void:
	_music_transition.play("ChangeToShopMusic")

func play_dirt_dig(randomizer: bool = true) -> void:
	for sfx in _dirt_digs:
		if sfx.playing:
			return
	var dirt_dig: AudioStreamPlayer = _dirt_digs.pick_random()
	if randomizer:
		dirt_dig.pitch_scale = _get_random_pitch()
	dirt_dig.play()

func play_stone_dig(randomizer: bool = true) -> void:
	for sfx in _stone_breaks:
		if sfx.playing:
			return
	var stone_break = _stone_breaks.pick_random()
	if randomizer:
		stone_break.pitch_scale = _get_random_pitch()
	stone_break.play()

func play_stone_dig_fail(randomizer: bool = true) -> void:
	if _claw_ricochet.playing:
		return
	if randomizer:
		_claw_ricochet.pitch_scale = _get_random_pitch()
	_claw_ricochet.play()

# podem usar isto para quando o player levar damage
func play_squeak(randomizer: bool = true) -> void:
	var squeak = _squeaks.pick_random()
	if randomizer:
		squeak.pitch_scale = _get_random_pitch()
	squeak.play()

func play_radar_pulse() -> void:
	_radar_pulse.play()
	play_squeak()

func play_click() -> void:
	_click.play()

func play_hover() -> void:
	_hover.play()
