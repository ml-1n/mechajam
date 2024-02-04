extends CharacterBody2D

# signals
signal just_dashed
signal just_shot
signal health_change(amount)
signal play_animation(name)
signal flip_horizontal(boolean)

# game stats
const MOVE_SPEED = 300.0
const DASH_DISTANCE = 8.0
const JUMP_SPEED = 400.0
const ACCELERATION = 0.2
const FRICTION = 0.2
const MAX_HEALTH = 100

# cooldowns
const DASH_COOLDOWN = 1.0
const SHOOT_COOLDOWN = 0.25

# iframe durations
const HARM_IFRAMES = 0.5
const DASH_IFRAMES = 0.5

@onready var projectile_type = load("res://entities/bullet.tscn")

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# limb switches
@onready var has_arms = true
@onready var has_legs = true
@onready var has_gun = true
@onready var has_dash = true

# action switches
@onready var can_shoot = true
@onready var can_dash = true
@onready var can_move = true
@onready var can_jump = true
@onready var can_harm = true
@onready var is_dashing = true
@onready var is_jumping = false

# other parts to call
@onready var hud = $HUD
@onready var body = $AnimatedSprite2D
@onready var legs = $Legs
@onready var arms = $Arms
@onready var gun = $Gun

var health = MAX_HEALTH

func _physics_process(delta):
	check_health()
	check_limbs()
	do_input()
	do_gravity(delta)
	move_and_slide()
	print(health)
	
# this is checked only when input actually occurs. will perform better
func _unhandled_input(event):
	
		# quit the game
		if Input.is_action_just_pressed("ui_cancel"):
			get_tree().quit()

func check_health():
	if health <= 0:
		# TODO INITIATE DEATH SCREEN HERE
		pass
	pass

func check_limbs():
	match has_arms:
		true:
			arms.process_mode = Node.PROCESS_MODE_INHERIT
			arms.visible = true
		false:
			arms.process_mode = Node.PROCESS_MODE_DISABLED
			arms.visible = false
		
	match has_legs:
		true:
			legs.process_mode = Node.PROCESS_MODE_INHERIT
			legs.visible = true
		false:
			legs.process_mode = Node.PROCESS_MODE_DISABLED
			legs.visible = false
		
	match has_gun:
		true:
			gun.process_mode = Node.PROCESS_MODE_INHERIT
			gun.visible = true
		false:
			gun.process_mode = Node.PROCESS_MODE_DISABLED
			gun.visible = false
		
	match has_dash:
		true:
			pass
			#dash.process_mode = Node.PROCESS_MODE_INHERIT
			#dash.visible = true
		false:
			pass
			#dash.process_mode = Node.PROCESS_MODE_DISABLED
			#dash.visible = false
	
#func play_animation(name: String):
	#legs.play(name)
	#arms.play(name)
	#body.play(name)
	#gun.play(name)
	
func do_input():
	var direction = get_direction()
	var mouse = get_global_mouse_position()
	
	# legs
	if has_legs:
		if Input.is_action_just_pressed("action_jump") && is_on_floor():
			velocity.y -= JUMP_SPEED
			is_jumping = true
			emit_signal("play_animation", "jump")
			
		elif is_jumping && is_on_floor():
			emit_signal("play_animation", "land")
			is_jumping = false
			
		# movement
		if direction:
			velocity.x = lerp(velocity.x, direction.x * MOVE_SPEED, ACCELERATION)
			
			if Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right"):
				emit_signal("play_animation", "move")

			else:
				emit_signal("play_animation", "idle")
		
		# decelerate if no direction
		else:
			velocity.x = lerp(velocity.x, 0.0, FRICTION)
			emit_signal("play_animation", "idle")
		
	# gun
	if has_gun:
		if Input.is_action_just_pressed("action_shoot"):
			shoot(mouse)
		
		# mouse look
		gun.rotation = get_angle_to(mouse)
	
	# dash
	if has_dash:
		if Input.is_action_just_pressed("action_dash") && direction:
			dash(direction)
			
	# mouse flipping
	if rad_to_deg(get_angle_to(mouse)) < -90:
		emit_signal("flip_horizontal", true)
		
	else:
		emit_signal("flip_horizontal", false)
		

func do_gravity(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		
func shoot(target):
	
	# end if no gun
	if !can_shoot:
		# TODO PLAY CAN'T SHOOT SOUND
		return
	
	var muzzle = $Gun/ShootMark.global_position
	var direction = muzzle.direction_to(target)
	
	# spawn projectile
	var projectile = projectile_type.instantiate()
	projectile.position = muzzle
	projectile.direction = direction
	get_parent().call_deferred("add_child", projectile) # add to parent so it moves independently of the player
	
	# apply recoil
	velocity -= projectile.RECOIL * direction
	
	# start cooldown
	can_shoot = false
	get_tree().create_timer(SHOOT_COOLDOWN).timeout.connect(func(): can_shoot = true)
	emit_signal("just_shot", SHOOT_COOLDOWN)
	
	# play animation
	emit_signal("play_animation", "shoot")

# TODO replace velocity with raw position jump
func dash(direction):
	
	# end if no dash. TODO is this always available? or just after losing limbs?
	if !can_dash:
		return
	
	## animate the jump in position
	#var tween = create_tween()
	#tween.tween_property(self, "position", position * direction * DASH_DISTANCE, 0.1)
	#
	velocity = direction * (MOVE_SPEED * DASH_DISTANCE)
	
	# start cooldown
	can_dash = false
	get_tree().create_timer(DASH_COOLDOWN).timeout.connect(func(): can_dash = true)
	
	# start iframes
	can_harm = false
	get_tree().create_timer(DASH_IFRAMES).timeout.connect(func(): can_harm = true; velocity = Vector2.ZERO)
	
	emit_signal("just_dashed", DASH_COOLDOWN)
	
func harm(amount):
	
	# end if in iframes
	if !can_harm:
		return
		
	# adjust health
	health -= amount
	
	# start iframes
	can_harm = false
	get_tree().create_timer(HARM_IFRAMES).timeout.connect(func(): can_harm = true)
	
	emit_signal("health_change", -amount)
	
func heal(amount):
	health += amount
	emit_signal("health_change", amount)
	
func get_direction():
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
