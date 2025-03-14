extends Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalDeathSignals.enemy_died.connect(_on_enemy_died)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	%TimerDisplay.set_text(str(get_time_left()))

func _on_enemy_died():
	wait_time += 5
	start()
