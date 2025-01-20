extends CharacterBody3D

@onready var sprite = $AnimatedSprite3D
@onready var detectionArea = $DetectionArea
var movement_vector = Vector3(0, 0, 0)
var walk_speed = 10
var health = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	pass

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var collision = move_and_collide(movement_vector * delta)
	
	if detectionArea.has_overlapping_bodies() == true:
		var overlappingBodies = detectionArea.get_overlapping_bodies()
		for body in overlappingBodies:
			if body.name == 'Player':
				sprite.billboard = 2
			else:
				sprite.billboard = 0
	if collision:
		print(collision.get_collider().name)

func takeDamage(amount):
	health -= amount
	print("Health remaining: ", health)
	if health <= 0:
		die()

func die():
	print("Character died")
	queue_free()
