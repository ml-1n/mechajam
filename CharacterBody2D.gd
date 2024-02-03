extends CharacterBody2D

@export var health = 100
@export var damage = 30
@export var MOVE_SPEED = 100

@export var player: Node2D
@onready var nav_agent :* $NavigationAgent2D as NavigationAgent2D

# Called when the node enters the scene tree for the first time.
func _ready():
	make_path()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir* floor_constant_speed
	move_and_slide()
	
func make_path() -> void:
	nav_agent.target_position = player.global_position
	
	func _on_timer_timeout():
		makepath()


func _on_timer_timeout():
	pass # Replace with function body.
