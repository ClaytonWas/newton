extends "res://scripts/guns/SpecialGun.gd"

# Functions
func _ready():
	damage = 100
	reloadSpeed = 10.0
	movementSpeed = 50
	currentCharge = 0.0

func _process(delta):
	# Charge the gun over time
	if currentCharge < reloadSpeed:
		currentCharge += 0.1 # Adjust charge rate based on delta time
		if currentCharge > reloadSpeed:
			currentCharge = reloadSpeed # Ensure it doesn't exceed reloadSpeed
	
	# Check for input
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot():
	if currentCharge >= reloadSpeed:
		print("Shooting!")
		currentCharge = 0.0 # Reset charge after shooting
	else:
		print("Gun is not charged! Current charge: ", currentCharge)
