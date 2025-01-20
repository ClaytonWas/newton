extends "res://scripts/enemies/enemy.gd"

func _ready():
	health = 50
	walk_speed = 10
	sprite.play("walkForward")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	pass

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass

func takeDamage(amount):
	super.takeDamage(amount)

func die():
	super.die()
