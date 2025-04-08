extends Node2D

@onready var music_transition: AnimationPlayer = $MusicTransition

var _squeaks: Array[AudioStreamPlayer] = []
var _dirt_digs: Array[AudioStreamPlayer] = []
var _stone_breaks: Array[AudioStreamPlayer] = []

func _ready() -> void:
	_squeaks = [$Squeak1, $Squeak2, $Squeak3]
	_dirt_digs = [$DirtDig1, $DirtDig2, $DirtDig3]
	_stone_breaks = [$StoneBreak1, $StoneBreak2]
	play_music()

func _get_random_pitch() -> float:
	return randf_range(0.9, 1.2)
	
func _get_random_volume() -> float:
	return randf_range(-1, 0)

func play_music() -> void:
	music_transition.play("ChangeToMainMusic")
	$Music.play()

func play_shop_music() -> void:
	music_transition.play("ChangeToShopMusic")
	#$ShopMusic.play()

func play_dirt_dig(randomizer: bool = true) -> void:
	var dirt_dig: AudioStreamPlayer = _dirt_digs.pick_random()
	if randomizer:
		dirt_dig.pitch_scale = _get_random_pitch()
		dirt_dig.volume_db = _get_random_volume()
	dirt_dig.play()
	
func play_stone_dig(randomizer: bool = true) -> void:
	var stone_break = _stone_breaks.pick_random()
	if randomizer:
		stone_break.pitch_scale = _get_random_pitch()
		stone_break.volume_db = _get_random_volume()
	stone_break.play()

func play_stone_dig_fail(randomizer: bool = true) -> void:
	if randomizer:
		$ClawRicochet.pitch_scale = _get_random_pitch()
		$ClawRicochet.volume_db = _get_random_volume()
	$ClawRicochet.play()

# podem usar isto para quando o player levar damage
func play_squeak(randomizer: bool = true) -> void:
	var squeak = _squeaks.pick_random()
	if randomizer:
		squeak.pitch_scale = _get_random_pitch()
		squeak.volume_db = _get_random_volume()
	squeak.play()

func play_radar_pulse() -> void:
	$RadarPulse.play()
	play_squeak()
