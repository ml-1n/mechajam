extends Node2D

const HEAL_AMOUNT = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if body.name.match("Player"):
		body.heal(HEAL_AMOUNT)
		queue_free()
