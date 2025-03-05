extends Enemy

func _ready():
	walk_speed = 15
	sprite.play("walkForward")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	pass
	
# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	sprite.billboard = 0
	movement_vector = Vector3.ZERO
	$AnimatedSprite3D.modulate = Color(1, 1, 1)
	
	global_transform.origin += movement_vector * delta
	
	var collision = move_and_collide(movement_vector * delta)

	if collision:
		if collision.get_collider().name == 'Player':
			print('Player hit by demon melee.')
			$AnimatedSprite3D.modulate = Color(1, 0, 0)
