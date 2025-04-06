extends Node2D

var _squeaks: Array[AudioStreamPlayer] = []
var _dirt_moves: Array[AudioStreamPlayer] = []

func _ready() -> void:
	_squeaks = [$Squeak1, $Squeak2, $Squeak3]
	_dirt_moves = [$DirtMove1, $DirtMove2, $DirtMove3]
	play_music()

func _get_random_pitch() -> float:
	return randf_range(0.9, 1.2)

func play_music() -> void:
	$Music.play()
	
func play_dirt_move(random_pitch: bool = true) -> void:
	if _dirt_moves.all(func(element): return not element.playing):
		var dirt_move = _dirt_moves.pick_random()
		if random_pitch:
			dirt_move.pitch_scale = _get_random_pitch()
			dirt_move.play()

func play_dirt_dig() -> void:
	if not $DirtDig.playing:
		$DirtDig.pitch_scale = _get_random_pitch()
		$DirtDig.play()
	
func play_stone_dig() -> void:
	if not $StoneDig.playing:
		$StoneDig.pitch_scale = _get_random_pitch()
		$StoneDig.play()

func play_stone_dig_fail() -> void:
	if not $StoneDigFail.playing:
		$StoneDigFail.pitch_scale = _get_random_pitch()
		$StoneDigFail.play()

# podem usar isto para quando o player levar damage
func play_squeak(random_pitch: bool = true) -> void:
	var squeak = _squeaks.pick_random()
	if random_pitch:
		squeak.pitch_scale = _get_random_pitch()
		squeak.play()

func play_radar_pulse() -> void:
	$RadarPulse.play()
	play_squeak()
