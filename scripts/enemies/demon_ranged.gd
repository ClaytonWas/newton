extends Enemy

var is_shooting: bool = false

func _ready():
	health = 50
	walk_speed = 5
	sprite.play("walkForward")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	pass

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$AnimatedSprite3D.modulate = Color(0, 0, 0)
	sprite.billboard = 0
	movement_vector = Vector3.ZERO
	
	if detectionArea.has_overlapping_bodies() == true:
		var overlappingBodies = detectionArea.get_overlapping_bodies()
		for body in overlappingBodies:
			if body.name == 'Player':
				shoot()
				$AnimatedSprite3D.modulate = Color(1, 1, 0)
				var direction_to_player = (body.global_transform.origin - global_transform.origin).normalized()
				movement_vector = -direction_to_player * walk_speed
				sprite.billboard = 2	
	
	velocity.y -= 9.8 * delta
	velocity.x = movement_vector.x
	velocity.z = movement_vector.z
	move_and_slide()


func takeDamage(amount):
	super.takeDamage(amount)

func die():
	super.die()

func shoot():
	if is_shooting:
		return
	
	is_shooting = true
	await get_tree().create_timer(1.5).timeout #seconds
	#spawn bullet
	await get_tree().create_timer(1).timeout #seconds
	is_shooting = false
	print("shooting!")
