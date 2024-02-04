extends CharacterBody2D

signal just_dashed
signal just_shot
signal health_change(amount)

const MOVE_SPEED = 300.0
const DASH_MULT = 4.0
const JUMP_SPEED = 450.0
const ACCELERATION = 0.2
const FRICTION = 0.2
const DASH_COOLDOWN = 1.0
const SHOOT_COOLDOWN = 0.25
const CAN_DAMAGE_COOLDOWN = 1

const MAX_HEALTH = 100
var health

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var projectile_type = load("res://entities/bullet.tscn")

var can_shoot
var can_dash
var can_move
var can_jump
var can_damage
var jumping

var has_arms
var has_legs
var has_gun

var hud

func _ready():
	can_shoot = true
	can_dash = true
	can_move = true
	can_jump = true
	can_damage = true
	
	has_arms = true
	has_legs = true
	has_gun = true
	
	health = MAX_HEALTH
	
	hud = get_tree().current_scene.get_node("HUD")
	
# this is synced and checked per-frame
func _physics_process(delta):
	var direction = get_direction()
	

	
	# jumping input
	if Input.is_action_just_pressed("action_jump") && is_on_floor() && can_jump && has_legs:
		velocity.y += -JUMP_SPEED
		jumping = true
		$LegsSprite.play("jump")
		$ArmsSprite.play("jump")
		$BodySprite.play("jump")
		
	# landing on jump
	elif is_on_floor() && jumping:
		$LegsSprite.play("land")
		$ArmsSprite.play("land")
		$BodySprite.play("land")
		jumping = false

	
	# shooting input		
	if Input.is_action_just_pressed("action_shoot") && can_shoot && has_gun:
		shoot()
	
	# dash input
	if Input.is_action_just_pressed("action_dash") && direction && can_dash:
		dash()
	
	# movement input
	if direction && can_move && has_legs:
		velocity.x = lerp(velocity.x, direction.x * MOVE_SPEED, ACCELERATION)
	
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION)
		
	# TODO Mouse input
		
	# process gravity
	if !is_on_floor():
		velocity.y += gravity * delta

	
	move_and_slide()
	
# this is checked only when input actually occurs. will perform better
func _unhandled_input(event):
	
		# quit the game
		if Input.is_action_just_pressed("ui_cancel"):
			get_tree().quit()
	
func check_limbs():
	if !has_gun:
		$Gun.disabled = true
		
	if !has_legs:
		$Legs.disabled = true
		
	if !has_arms:
		$Arms.disabled = false
		
func shoot():
	
	# end if no gun
	if !has_gun:
		return
	
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
	emit_signal("just_shot", SHOOT_COOLDOWN)

# TODO clamp/normalize velocity (due to gravity), add iframes
func dash():
	
	# in case we still have legs
	#if !can_dash:
		#return
	var direction = get_direction()
	
	velocity = direction * (MOVE_SPEED * DASH_MULT)
	
	# start cooldown
	can_dash = false
	#can_damage = false
	get_tree().create_timer(DASH_COOLDOWN).timeout.connect(func(): can_dash = true)
	emit_signal("just_dashed", DASH_COOLDOWN)
	
func take_damage(amount):
	if can_damage:
		health -= amount
		emit_signal("health_change", amount)
		print(health)
		can_damage = false
		get_tree().create_timer(CAN_DAMAGE_COOLDOWN).timeout.connect(func(): can_damage = true)
	
func get_direction():
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
