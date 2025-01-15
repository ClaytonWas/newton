extends "res://scripts/guns/Gun.gd"

# Common Variables
var currentCharge = reloadSpeed

# Functions
func shoot():
	if currentCharge == reloadSpeed:
		print("Shooting!")
	else:
		print("Gun is not charged!")

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()
