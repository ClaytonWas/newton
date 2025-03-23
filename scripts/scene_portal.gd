extends Area3D

@export var scene_path: String = "res://scenes/UI/shop.tscn"

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" and scene_path:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file( "res://scenes/UI/shop.tscn")
