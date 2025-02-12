extends CharacterBody3D

# How fast the player moves in meters per second.
@export var max_speed = 25
# Acceleration and deceleration rates in meters per second squared for movement.
@export var acceleration = 1000
@export var deceleration = 400
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# Jump strength in meters per second.
@export var jump_strength = 30
# Mouse sensitivity
@export var mouse_sensitivity = 0.002
# How fast the camera returns to normal position
@export var camera_return_speed = 5.0

@export_category("Weapon Variables")
@export var inventory: Array[Weapon] = []
@export var equipped_weapon : Weapon

@onready var camera = $Camera3D

var target_velocity = Vector3.ZERO
var current_velocity = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	equipped_weapon = inventory[0]
	
	$right_hand.find_child(equipped_weapon.weapon_name).visible = true
	

func _input(event):	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("reload"):
		reload()		
		
	if event is InputEventMouseMotion:
		# Rotate left/right always happens
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Rotate up/down only when middle mouse is pressed
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, -PI/3, PI/4)
			
#Swap between weapons
	if event.is_action_pressed("slot1"):
		changeWeapon(inventory[0])
		
	if event.is_action_pressed("slot2"):
		changeWeapon(inventory[1])
		

func _physics_process(delta):
	var direction = Vector3.ZERO

	# Return camera to normal position when middle mouse is not pressed
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		camera.rotation.x = lerp(camera.rotation.x, 0.0, camera_return_speed * delta)
	
	# Gather input for movement
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	# Normalize and rotate the direction vector
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		direction = direction.rotated(Vector3.UP, rotation.y)

	# Apply acceleration/deceleration for both horizontal and vertical movements
	# Smoothly adjust current velocity for both axes
	if direction != Vector3.ZERO:
		target_velocity.x = direction.x * max_speed
		target_velocity.z = direction.z * max_speed
	else:
		# Decelerate to stop when no input
		target_velocity.x = move_toward(current_velocity.x, 0, deceleration * delta)
		target_velocity.z = move_toward(current_velocity.z, 0, deceleration * delta)

	# Apply gravity when in the air
	if not is_on_floor():
		current_velocity.y -= fall_acceleration * delta
	elif Input.is_action_pressed("jump"):
		current_velocity.y = jump_strength  # Jump if on the floor and jump key is pressed

	# Accelerate/decelerate on x, y, and z directions
	current_velocity.x = move_toward(current_velocity.x, target_velocity.x, acceleration * delta)
	current_velocity.z = move_toward(current_velocity.z, target_velocity.z, acceleration * delta)

	# Move the character
	velocity = current_velocity
	move_and_slide()

func changeWeapon(gun:Weapon):
	print("magsize/reserve/reloadtime/mag %d/%d/%d/%d", inventory.size())
	var old_gun = equipped_weapon
	
	equipped_weapon = gun
	
	#$gun.weapon_type = gun
	
	#Jank Code, need to either replace one node OR create new one
	$right_hand.find_child(old_gun.weapon_name).visible = false
	$right_hand.find_child(equipped_weapon.weapon_name).visible = true
	print('Switched to ',gun.weapon_name,' dealing ',gun.damage,' per shot.')
	print("magsize/reserve/reloadtime/mag %d/%d/%d/%d",gun.magazine_size, gun.reload_time, gun.mag)
	
	
		#$right_hand.add_child(new_gun)
	
func fireHitscan():
	var hitObject = self.raycast.force_raycast_update()
	
	if hitObject is CharacterBody3D:
		print("Hit: ", hitObject)
		hitObject.takeDamage(equipped_weapon.damage)
	elif hitObject is Node3D:
		print("Hit: ", hitObject)

func shoot():
	if equipped_weapon.mag > 0:
		equipped_weapon.shoot()				#Handles ammo count
		print("Shooting from %s!",equipped_weapon.weapon_name)
		
		var hitObject = self.find_child("Camera3D").find_child("RayCast3D").get_collider()
		
		if "Demon" in hitObject.name:
			print("Hit: ", hitObject.name)
			hitObject.takeDamage(equipped_weapon.damage)

	else:
		print("Out of ammo!")

func reload():
	print(equipped_weapon, equipped_weapon.reload_time)
	var timer = Timer.new()
	self.add_child(timer)
	timer.wait_time = equipped_weapon.reload_time
	timer.start()
	
	#play equipped_weapon.dryfire_sound
	equipped_weapon.reload()
