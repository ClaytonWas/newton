extends "res://scripts/guns/Gun.gd"

# Common Variables
var magazineSize = 7
var remainingInMagazine = 7

# Functions
func reload():
	print("Reloading...")
	await get_tree().create_timer(reloadSpeed).timeout
	remainingInMagazine = magazineSize
	print("Reload Complete")

func shoot():
	if remainingInMagazine > 0:
		print("Shooting!")
		remainingInMagazine -= 1
	else:
		print("Out of ammo!")

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("reload"):
		reload()
