extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var shoot_bar = $ShootBar
@onready var dash_bar = $DashBar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_player_health_change(amount):
	health_bar.change(amount)
	
func _on_player_just_dashed(time):
	dash_bar.cooldown(time)

func _on_player_just_shot(time):
	shoot_bar.cooldown(time)
