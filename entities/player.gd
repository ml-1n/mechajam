extends CharacterBody2D

const MOVE_SPEED = 300.0
const DASH_SPEED = 4
const JUMP_SPEED = -400.0
const ACCELERATION = 0.05
const FRICTION = 0.05

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var projectile_type = load("res://entities/bullet.tscn")


func _physics_process(delta):

	# process vertical gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# horizontal movement/sliding
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction && Input.is_action_just_pressed("action_dash"):
			dash(direction)
			
	elif direction:
			velocity.x = lerp(velocity.x, direction * MOVE_SPEED, ACCELERATION)
			
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION)
		
	move_and_slide()
	
func _input(event):
			
		if Input.is_action_pressed("move_up") && is_on_floor():
			jump()
			
		if Input.is_action_pressed("action_shoot"):
			shoot()
			
		elif Input.is_action_pressed("action_dash") && (Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right")):
			dash(Input.get_axis("move_left", "move_right"))
	
func shoot():
	var projectile = projectile_type.instantiate()
	var recoil = projectile.RECOIL
	
	var origin = global_position
	var target = get_global_mouse_position()
	var direction = origin.direction_to(target)
	
	projectile.position = global_position
	projectile.direction = direction
	
	velocity += recoil * -direction
	
	
	get_parent().call_deferred("add_child", projectile)
	
	
func move():
	move_and_slide()
	
func jump():
	if is_on_floor():
		velocity.y = JUMP_SPEED
	
func dash(direction):
	
	# IFRAMES ON
	velocity.x += direction * 400
	# IFRAMES OFF
