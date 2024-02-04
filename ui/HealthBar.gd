extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = get_tree().current_scene.get_node("player").MAX_HEALTH
	value = max_value
	show_percentage = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func change(amount):
	var tween = create_tween()
	tween.tween_property(self, "value", value - amount, 0.1)
