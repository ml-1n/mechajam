extends CharacterBody2D

const ATTACK_LENGTH = 0.5
const DEATH_LENGTH = .75
const MAX_HEALTH = 100

@export var health: int
@export var damage = 30
@export var MOVE_SPEED = 40

@export var player: Node2D
@export var projectile_type = load("res://entities/goo_bullet.tscn")
@onready var tile_map:= $"../../Ground/TileMap" as TileMap 

@onready var anim_sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var waiting = false
@onready var enemy = true
@onready var gravity = 50

@onready var dow_mark = $DownMarker
@onready var for_mark = $ForwardMarker
@onready var fall_mark = $FallMarker
@onready var eye_mark = $EyeMarker

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().current_scene.get_node("player")
	health = MAX_HEALTH
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	die_if_die()
	check_attack()
	crawl(delta)



# MOVEMENT

# For crawler i think ill just have them move back and forth on their particular platform
# and stop and shoot when player is in sight
# And ignore gravity, so they can be on the walls or ceiling (automatically orient? Or manually set?)

# a function to translate text direction and return a Vector2 direction multiplier

# Lin suggested to put a marker directly down on the sprite, and you get the gravity direction with direction_to
# and this way it can be rotated in the editor to place it wherever and automatically make it stick

# The last issue is making it not fall off ledges. I think I'll put a marker in front and down of it, that
# checks if it is over a space tile. If it is not, it'll keep walking. If it is, it'll turn the other direction

# I will do this. Apply gravity via down marker. Go forward via forward marker. Check for collisions with forward marker
# With Fall marker check for ledges

# okay current problem is that i need to both set the x with formark and y with downmark

func crawl(delta):
	apply_gravity()
	if !waiting:
		anim_sprite.play("crawl")
		move_checks()
		velocity += global_position.direction_to(for_mark.global_position).normalized() * MOVE_SPEED
	move_and_slide()

func apply_gravity():
	velocity = global_position.direction_to(dow_mark.global_position).normalized() * gravity

func move_checks():
	# First check if we are about to bump into something
	# var the forward marker's global position
	# compare it to the tile at that global position
	# if that tile has collision? Maybe if its on layer 1, the playground layer
	# then turn around
	var for_mark_tile = tile_map.local_to_map(tile_map.to_local(for_mark.global_position))
	var for_data = tile_map.get_cell_tile_data(1, for_mark_tile)

	var fall_mark_tile = tile_map.local_to_map(tile_map.to_local(fall_mark.global_position))
	var fall_data = tile_map.get_cell_tile_data(1, fall_mark_tile)
	
	if for_data || !fall_data:
		print("turning")
		turn_around()
	# Then check if we're about to fall off a ledge
	# var the fall marker's global position
	# compare it to the tile at that global position
	# if that tile has collision? Maybe if it is NOT on layer 1, the playground layer
	# then turn around


func turn_around():
	for_mark.position = for_mark.position * Vector2(-1,1)
	fall_mark.position = fall_mark.position * Vector2(-1,1)
	if anim_sprite.flip_h:
		anim_sprite.flip_h = false
	else:
		anim_sprite.flip_h = true

# ATTACKING

func check_attack():
	# Checks if it can attack, have to be in range of the player
	# Have to have line of sight. Gonna use raycasting
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(eye_mark.global_position, player.position)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	print(result.collider)
	if result.collider == player && waiting == false:
		anim_sprite.play("ready")
		waiting = true
		$AttackTimer.start()


func attack():
	#makes a timer, during this time it is attacking
	get_tree().create_timer(ATTACK_LENGTH).timeout.connect(func(): waiting = false )
	# Changes animation to the shootey sprite
	anim_sprite.play("squirt")
	# Creates squirt projectile
	var projectile = projectile_type.instantiate()
	
	var origin = eye_mark.global_position
	var target = player.global_position
	var direction = origin.direction_to(target)
	
	projectile.position = global_position
	projectile.direction = direction
	projectile.rotation = direction.angle()
	projectile.creator = self
	
	# rotate projectile to be pointed at player. Maybe pick a point along the ray?
	
	get_parent().call_deferred("add_child", projectile)

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
	attack()
	
