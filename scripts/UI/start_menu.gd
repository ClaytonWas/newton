extends Control

@export_category('Scenes')
@export var main_scene_path: String = "res://scenes/levels/outdoors.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_button_button_down() -> void:
	get_tree().quit()


func _on_play_button_button_down() -> void:
	get_tree().change_scene_to_file(main_scene_path)
