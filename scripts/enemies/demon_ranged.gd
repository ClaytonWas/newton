extends "res://scripts/enemies/enemy.gd"

func _ready():
	health = 50
	walk_speed = 1
	sprite.play("walkForward")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if position.x > 10:
		movement_vector.x = -walk_speed
	elif position.x < 0:
		movement_vector.x = walk_speed

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func takeDamage(amount):
	super.takeDamage(amount)

func die():
	super.die()
