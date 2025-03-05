class_name Enemy extends CharacterBody3D

@onready var sprite = $AnimatedSprite3D
@onready var detectionArea = $DetectionArea
var movement_vector = Vector3(0, 0, 0)
@export_category("Enemy Stats")
@export var walk_speed = 10
@export var attack_dmg = 20
@export var vision_radius = 50

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	sprite.billboard = 0
	var collision = move_and_collide(movement_vector * delta)
	
	if collision:
		print(collision.get_collider().name)
