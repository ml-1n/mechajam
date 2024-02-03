extends CharacterBody2D

const MOVE_SPEED = 300.0
const DASH_MULT = 4.0
const JUMP_SPEED = 450.0
const ACCELERATION = 0.2
const FRICTION = 0.2
const DASH_COOLDOWN = 1.0
const SHOOT_COOLDOWN = 0.25

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var projectile_type = load("res://entities/bullet.tscn")
var can_shoot = true
var can_dash = true
var can_move = true
var can_jump = true

# this is synced and checked per-frame
func _physics_process(delta):
	var direction = get_direction()
	
	# jumping input
	if Input.is_action_just_pressed("action_jump") && is_on_floor() && can_jump:
		velocity.y += -JUMP_SPEED
	
	# shooting input		
	if Input.is_action_just_pressed("action_shoot") && can_shoot:
		shoot()
	
	# dash input
	if Input.is_action_just_pressed("action_dash") && direction && can_dash:
		dash()
	
	# movement input
	if direction && can_move:
		velocity.x = lerp(velocity.x, direction.x * MOVE_SPEED, ACCELERATION)
	
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION)
		
	# process gravity
	if !is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()
	
# this is checked only when input actually occurs. will perform better
func _unhandled_input(event):
	
		# quit the game
		if Input.is_action_just_pressed("ui_cancel"):
			get_tree().quit()
	
func shoot():
	var projectile = projectile_type.instantiate()
	
	var origin = global_position
	var target = get_global_mouse_position()
	var direction = origin.direction_to(target)
	
	projectile.position = global_position
	projectile.direction = direction
	
	velocity += projectile.RECOIL * -direction
	
	get_parent().call_deferred("add_child", projectile)
	
	# start cooldown
	can_shoot = false
	get_tree().create_timer(SHOOT_COOLDOWN).timeout.connect(func(): can_shoot = true)
	
func dash():
	var direction = get_direction()
	
	# IFRAMES ON
	velocity = direction * (MOVE_SPEED * DASH_MULT)
	# IFRAMES OFF
	
	# start cooldown
	can_dash = false
	get_tree().create_timer(DASH_COOLDOWN).timeout.connect(func(): can_dash = true)
	
func get_direction():
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
