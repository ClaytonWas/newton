extends "res://scripts/guns/AmmoGun.gd"

# Functions
func _ready():
	damage = 100
	reloadSpeed = 2
	movementSpeed = 75
	magazineSize = 2
	remainingInMagazine = 2

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("reload"):
		reload()
	
func shoot():
	super.shoot()

func reload():
	super.reload()
