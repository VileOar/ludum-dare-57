extends Control

func play_animation() -> void:
	$AnimatedSprite2D.play("default")

func stop_animation() -> void:
	$AnimatedSprite2D.stop()
