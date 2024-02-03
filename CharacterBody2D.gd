class_name Enemy extends CharacterBody2D

@export var health = 100
@export var damage = 30
@export var MOVE_SPEED = 30

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().current_scene.get_node("player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta) -> void:
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * MOVE_SPEED
	move_and_slide()

func make_path() -> void:
	nav_agent.target_position = player.global_position


func _on_timer_timeout():
	make_path()
