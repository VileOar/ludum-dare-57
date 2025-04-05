extends Area2D

@onready var player: CharacterBody2D = $".."


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		print("body entered")
		var enemy:Enemy = body as Enemy
		enemy.enemy_collided_with_player()
		player.lose_health()
