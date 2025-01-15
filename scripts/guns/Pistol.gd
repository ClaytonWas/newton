extends "res://scripts/guns/AmmoGun.gd"

# Functions
func _ready():
	damage = 50
	reloadSpeed = 0.7
	movementSpeed = 50
	magazineSize = 7
	remainingInMagazine = 3

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("reload"):
		reload()
	
func shoot():
	super.shoot()

func reload():
	super.reload()
