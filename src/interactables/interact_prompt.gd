extends Control

func play_animation() -> void:
	$AnimationPlayer.play("Idle")

func stop_animation() -> void:
	$AnimationPlayer.stop()
