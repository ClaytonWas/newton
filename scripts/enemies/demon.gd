extends "res://scripts/enemies/enemy.gd"

func _ready():
	walk_speed = 15
	health = 200
	sprite.play("walkForward")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	pass
	
# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	sprite.billboard = 0
	movement_vector = Vector3.ZERO
	
	if detectionArea.has_overlapping_bodies() == true:
		var overlappingBodies = detectionArea.get_overlapping_bodies()
		for body in overlappingBodies:
			if body.name == 'Player':
				var direction_to_player = (body.global_transform.origin - global_transform.origin).normalized()
				movement_vector = direction_to_player * walk_speed
				sprite.billboard = 2	
	
	print("Movement Vector Magnitude: ", movement_vector.length(), movement_vector)
	global_transform.origin += movement_vector * delta
	
	var collision = move_and_collide(movement_vector * delta)

	if collision:
		if collision.get_collider().name == 'Player':
			print('Player hit by demon melee.')

func takeDamage(amount):
	super.takeDamage(amount)

func die():
	super.die()
