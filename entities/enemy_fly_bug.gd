extends CharacterBody2D

const ATTACK_LENGTH = 0.5
const DEATH_LENGTH = .75
const MAX_HEALTH = 100
@export var health: int
@export var damage = 30
@export var MOVE_SPEED = 50

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var anim_sprite := $AnimatedSprite2D as AnimatedSprite2D

@onready var attack_timer = $AttackTimer
@onready var waiting = false
@onready var harmful = false
@onready var enemy = true

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().current_scene.get_node("Player")
	health = MAX_HEALTH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	die_if_die()
	check_attack()
	navigate()
	var collision = move_and_collide(velocity * delta)
	if collision && collision.get_collider() == player  && harmful:
		player.harm(damage)



# MOVEMENT

func navigate():
	if !waiting:
		anim_sprite.play("fly")
		var dir = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = dir * MOVE_SPEED
	
func make_path() -> void:
	nav_agent.target_position = player.global_position

func _on_timer_timeout():
	make_path()

# ATTACKING

func check_attack():
	# Checks if it can attack, have to be in range of the player
	if global_position.distance_to(player.global_position) < 100 && waiting == false:
		anim_sprite.play("fly")
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

func harm(damage):
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
	attack()
	
