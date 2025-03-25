extends Control

var was_clicked: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Engine.time_scale = 0.0
	#toggle_pause()
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ok_pressed() -> void:
	was_clicked = true
	Engine.time_scale = 1.0
