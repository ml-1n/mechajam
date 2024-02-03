extends CharacterBody2D

@export var health = 100
@export var damage = 30
@export var MOVE_SPEED = 50

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var anim_sprite := $AnimatedSprite2D as AnimatedSprite2D

@onready var attack_timer = $AttackTimer
@onready var attacking = false
@onready var harmful = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().current_scene.get_node("player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta) -> void:
	die_if_die()
	check_attack()
	navigate()
	move_and_slide()


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
		print("in range")
		attacking = true
		$AttackTimer.start()
		# If yes, backs up a little, waits till Attack Timer is 0, then attacks
		if $AttackTimer.time_left <= 0.0:
			print('attacking')
			attack()
		else:
			velocity = position.direction_to(player.global_position) * -10


func attack():
	# Changes animation to the bitey sprite
	anim_sprite.play("bite")
	# Sets velocity to charge at player at high speed
	velocity = position.direction_to(player.global_position) * 200
	# Sets self to harmful (and player is set to take damage if they hit something with the harmful variable.
	pass


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
	attacking = false
