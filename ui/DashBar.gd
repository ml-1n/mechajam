extends ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	value = max_value
	fill_mode = FILL_BOTTOM_TO_TOP
	show_percentage = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func cooldown(time):
	value = 0.0
	var tween = create_tween()
	tween.tween_property(self, "value", 100, time)
