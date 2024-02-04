extends Area2D

const SPEED = 400
const RECOIL = 200
const DAMAGE = 100

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
	#If the node of the body is under the Enemies node, then it is an enemy.
	if body is CharacterBody2D && body.enemy:
		body.take_damage(DAMAGE)
	queue_free()
