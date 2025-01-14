extends "res://scripts/guns/AmmoGun.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	damage = 100
	reloadSpeed = 0.7
	movementSpeed = 50
	magazineSize = 3
	remainingInMagazine = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("reload"):
		reload()
	
func shoot():
	super.shoot()

func reload():
	super.reload	()
