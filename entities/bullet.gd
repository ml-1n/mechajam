extends Area2D

const BASE_SPEED = 400
const RECOIL = 20

var direction
var origin
var target


# Called when the node enters the scene tree for the first time.
func _ready():
	origin = global_position
	target = get_global_mouse_position()
	direction = origin.direction_to(target)

func _physics_process(delta):
	position += direction * delta * BASE_SPEED
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
