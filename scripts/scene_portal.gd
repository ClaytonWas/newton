extends Area3D

@export var target_scene: PackedScene  # Drag and drop the target scene in the Inspector

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" and target_scene:
		get_tree().change_scene_to_packed(target_scene)  # Load the new scene
