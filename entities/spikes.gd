extends Area2D

@export var damage = 50


func _on_body_entered(body):
	if body is CharacterBody2D:
		if body.name == "Player":
			body.harm(damage)
		elif body.get_parent().name == "Enemies":
			body.harm(damage)
		else:
			return
