extends CharacterBody2D


const BASE_SPEED = 300.0
const DASH_SPEED = BASE_SPEED * 4
const JUMP_VELOCITY = -400.0
const PROJECTILE_TYPE = load("res://entities/projectile.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):

	# process gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
func _input(event):
		if event.is_action_pressed("move_left") || event.is_action_pressed("move_right"):
			move()
		
		elif event.is_action_pressed("move_up"):
			jump()
			
		if event.is_action_pressed("action_shoot"):
			shoot()
			
		elif event.is_action_pressed("action_dash"):
			dash()
	
func shoot():
	var projectile = PROJECTILE_TYPE.instantiate()
	get_parent().call_deferred("add_child", projectile)
	
	# Recoil
	
	
	
func move():
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * BASE_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, BASE_SPEED)
	
	move_and_slide()
	
func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
func dash():
	
	# IFRAMES ON
	move()
	# IFRAMES OFF
