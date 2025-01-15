extends Node3D

var currentFrame = Vector2i.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	var sprite3D = $Sprite3D
	sprite3D.set_vframes(1)
	sprite3D.set_hframes(4)
	sprite3D.set_frame_coords(currentFrame)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
