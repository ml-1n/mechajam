extends Area2D

const SPEED = 300
const DAMAGE = 20
@onready var creator: CharacterBody2D

var direction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	position += direction * delta * SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	#if is creator's body, ignore
	#Otherwise check if its a characterbody, and do damage
	#destroy self
	if body == creator:
		return
	if body is CharacterBody2D && not (body == creator):
		if body.name == "Player":
			body.harm(DAMAGE)
		elif body.get_parent().name == "Enemies":
			body.harm(DAMAGE)
		else:
			return
	queue_free()
