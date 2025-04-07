extends Area2D

@onready var player: CharacterBody2D = $".."

func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		var enemy:Enemy = body as Enemy
		if enemy:
			print("Enemy collided with player")
			enemy.enemy_collided_with_player()
			player.lose_health()
	
	if body.is_in_group(Global.INTERACTABLE_GROUP):
		if player.get_available_interactables().is_empty():
			# If there aren't any other available interactables then
			# save this one as the current and enter the interaction
			player.add_interactable(body)
			body.enter_interaction()
			player.set_current_interactable(body)
		else:
			player.add_interactable(body)

func _on_body_exited(body: Node2D) -> void:
	# Make sure that the body detected is interactable
	if body.is_in_group(Global.INTERACTABLE_GROUP):
		
		body.exit_interaction()
		player.get_available_interactables().erase(body)
