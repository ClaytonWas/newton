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
	if remainingInMagazine > 0:
		print("Shooting from AmmoGun!")
		fireHitscan()
		remainingInMagazine -= 1
	else:
		print("Out of ammo!")

func reload():
	super.reload()
	
	
func fireHitscan():
	var hitObject = super.fireHitscan()
	if hitObject is CharacterBody3D:
		print("Hit: ", hitObject)
		hitObject.takeDamage(damage)
	elif hitObject is Node3D:
		print("Hit: ", hitObject)
