extends CharacterBody2D

const ATTACK_LENGTH = 0.5
const MAX_HEALTH = 100
@export var health: int
@export var damage = 30
@export var MOVE_SPEED = 50

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var anim_sprite := $AnimatedSprite2D as AnimatedSprite2D

@onready var attack_timer = $AttackTimer
@onready var attacking = false
@onready var harmful = false
@onready var enemy = true

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().current_scene.get_node("player")
	health = MAX_HEALTH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	die_if_die()
	check_attack()
	navigate()
	var collision = move_and_collide(velocity * delta)
	if collision && collision.get_collider() == player  && harmful:
		player.take_damage(damage)



# Move stuff

func navigate():
	if !attacking:
		anim_sprite.play("fly")
		var dir = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = dir * MOVE_SPEED
	
func make_path() -> void:
	nav_agent.target_position = player.global_position

func _on_timer_timeout():
	make_path()

	# Attacking
func check_attack():
	# Checks if it can attack, have to be in range of the player
	if global_position.distance_to(player.global_position) < 100 && attacking == false:
		anim_sprite.play("fly")
		print("in range")
		attacking = true
		$AttackTimer.start()
		# If yes, backs up a little, waits till Attack Timer is 0, then attacks
		velocity = position.direction_to(player.global_position) * -10


func attack():
	#makes a timer, during this time it is attacking
	get_tree().create_timer(ATTACK_LENGTH).timeout.connect(func(): attacking = false ; harmful = false )
	# Changes animation to the bitey sprite
	anim_sprite.play("bite")
	# Sets velocity to charge at player at high speed
	velocity = position.direction_to(player.global_position) * 200
	#if collides with player, damage
	harmful = true


func take_damage(damage):
	health += -damage

# Dying
func die_if_die():
	# Not complete but the idea is that it checks if dead, if dead, stops movement/actions
	# plays death animation, and then queue_frees itself a second after the animation is done
	# possibly using a timer node
	if health <= 0:
		anim_sprite.play("die")
		# then it would ativate the death timer, to ensure like, a cool paced death
		queue_free()

func _on_attack_timer_timeout():
	print('attacking')
	attack()
	
