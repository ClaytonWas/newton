extends "res://scripts/guns/AmmoGun.gd"

@onready var raycast = $RayCast3D

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
	raycast.force_raycast_update()  # Ensure the raycast checks for collisions immediately
	if raycast.get_collider() != null:
		var hit_object = raycast.get_collider()
		if hit_object is CharacterBody3D:
			print("Hit: ", hit_object)
		hit_object.takeDamage(damage)
	else:
		print("No hit detected")
