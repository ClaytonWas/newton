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


# Called when the node enters the scene tree for the first time.
func _ready():
	print(ready)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
