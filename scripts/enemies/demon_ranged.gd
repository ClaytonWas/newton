extends Enemy

var is_shooting: bool = false

func _ready():
	walk_speed = 5
	sprite.play("walkForward")

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$AnimatedSprite3D.modulate = Color(0, 0, 0)
	sprite.billboard = 0
	movement_vector = Vector3.ZERO

	velocity.y -= 9.8 * delta
	velocity.x = movement_vector.x
	velocity.z = movement_vector.z
	move_and_slide()

func shoot():
	if is_shooting:
		return
	
	is_shooting = true
	await get_tree().create_timer(1.5).timeout #seconds
	#spawn bullet
	await get_tree().create_timer(1).timeout #seconds
	is_shooting = false
	print("shooting!")
