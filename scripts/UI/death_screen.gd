extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_death_screen():
	visible = true


func _on_button_pressed():
	print('Trying again\n\n\n')
	get_tree().change_scene_to_file("res://scenes/levels/start_menu.tscn")


func _on_quit_button_button_down() -> void:
	print('Pressed quit\n\n\n')
	get_tree().quit()


func _on_restart_button_down() -> void:
	Engine.time_scale = 1.0
	_on_button_pressed()
