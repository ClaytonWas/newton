extends Node3D

# Common Variables
var damage = 25
var reloadSpeed = 1.5
var movementSpeed = 100

# Functions
func shoot():
	print("Shoot call from Gun.gd.")

func alternateShoot():
	print("Alternate call from Gun.gd.")

func _ready():
	print(ready)

func _process(delta):
	pass
