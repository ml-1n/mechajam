extends Area2D

const BASE_SPEED = 400
const RECOIL = 200

var direction


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _physics_process(delta):
	position += direction * delta * BASE_SPEED
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
