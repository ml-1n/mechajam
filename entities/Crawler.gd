extends CharacterBody2D

const ATTACK_LENGTH = 0.5
const DEATH_LENGTH = .75
const MAX_HEALTH = 100

@export var health: int
@export var damage = 30
@export var MOVE_SPEED = 40
@export var gravity_direction = "down"
@export var direction = 'right'

@export var player: Node2D

@onready var anim_sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var waiting = false
@onready var harmful = false
@onready var enemy = true
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().current_scene.get_node("player")
	health = MAX_HEALTH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	die_if_die()
	check_attack()
	apply_gravity()
	crawl()
	var collision = move_and_collide(velocity * delta)
	if collision && collision.get_collider() == player  && harmful:
		player.take_damage(damage)



# MOVEMENT

# For crawler i think ill just have them move back and forth on their particular platform
# and stop and shoot when player is in sight
# And ignore gravity, so they can be on the walls or ceiling (automatically orient? Or manually set?)

# a function to translate text direction and return a Vector2 direction multiplier

# Lin suggested to put a marker directly down on the sprite, and you get the gravity direction with direction_to
# and this way it can be rotated in the editor to place it wherever and automatically make it stick

# The last issue is making it not fall off ledges. I think I'll put a marker in front and down of it, that
# checks if it is over a space tile. If it is not, it'll keep walking. If it is, it'll turn the other direction

func navigate():
	if !waiting:
		anim_sprite.play("crawl")
		#var dir = to_local(nav_agent.get_next_path_position()).normalized()
		#velocity = dir * MOVE_SPEED
	
func move_and_check_collision(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = Vector2(0,0)

func apply_gravity():
	pass

func translate_direction(direction):
	match direction:
		"right": return Vector2(1,0)
		"left": return Vector2(-1,0)
		"down": return Vector2(0,1)
		"up": return Vector2(0,-1)

# ATTACKING

func check_attack():
	# Checks if it can attack, have to be in range of the player
	if global_position.distance_to(player.global_position) < 100 && waiting == false:
		anim_sprite.play("fly")
		print("in range")
		waiting = true
		$AttackTimer.start()
		# If yes, backs up a little, waits till Attack Timer is 0, then attacks
		velocity = position.direction_to(player.global_position) * -10


func attack():
	#makes a timer, during this time it is attacking
	get_tree().create_timer(ATTACK_LENGTH).timeout.connect(func(): waiting = false ; harmful = false )
	# Changes animation to the bitey sprite
	anim_sprite.play("bite")
	# Sets velocity to charge at player at high speed
	velocity = position.direction_to(player.global_position) * 200
	#if collides with player, damage
	harmful = true

# DAMAGE AND DYING

func take_damage(damage):
	health += -damage

func die_if_die():
	# if dead, stops movement/actions
	# plays death animation, and then queue_frees itself a second after the animation is done
	# possibly using a timer node
	if health <= 0:
		get_tree().create_timer(DEATH_LENGTH).timeout.connect(func(): queue_free() )
		waiting = true
		velocity = Vector2(0,0)
		anim_sprite.play("die")

func _on_attack_timer_timeout():
	print('attacking')
	attack()
	
