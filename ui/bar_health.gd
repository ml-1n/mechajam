extends ProgressBar

@onready var player = get_tree().current_scene.get_node("Player")

func _ready():
	max_value = player.MAX_HEALTH
	value = player.health
	show_percentage = false

#func _process(delta):
	#pass
	
func change(amount):
	var tween = create_tween()
	tween.tween_property(self, "value", value - amount, 0.1)
