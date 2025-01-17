extends "res://scripts/guns/Gun.gd"

# Common Variables
@onready var raycast: RayCast3D = $RayCast3D
var magazineSize = 7
var remainingInMagazine = 7
var isReloading = false

# Functions
func reload():
	if isReloading:
		return
		
	if remainingInMagazine < magazineSize:
		print("Reloading...")
		isReloading = true
		await get_tree().create_timer(reloadSpeed).timeout
		remainingInMagazine = magazineSize
		print("Reload Complete")
		isReloading = false

func shoot():
	if remainingInMagazine > 0:
		print("Shooting from AmmoGun!")
		remainingInMagazine -= 1
	else:
		print("Out of ammo!")

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("reload"):
		reload()

func fireHitscan():
	raycast.force_raycast_update()
	return raycast.get_collider()
