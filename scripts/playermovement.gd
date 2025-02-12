extends CharacterBody3D

@export_category("Camera Controls")
@export var mouse_sensitivity := 0.002
const headbob_shake := 0.025
const headbob_frequency := 0.5
@export var headbob_time := 0.0

@export_category("Movement Variables")
@export var walk_speed := 30.0
@export var sprint_speed := 100.0
@export var jump_strength := 14.0
@export var air_speed_cap := 0.85
@export var air_speed_acceleration := 800.0
@export var air_move_speed := 500.0
@export var ground_speed_acceleration := 7.5
@export var ground_speed_deceleration := 7.5
@export var ground_friction := 5

@export_category("Weapon Variables")
@export var inventory: Array[Weapon] = []
@export var equipped_weapon : Weapon

var target_velocity = Vector3.ZERO
var current_velocity = Vector3.ZERO

var desired_direction := Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	equipped_weapon = inventory[0]
	
	$right_hand.find_child(equipped_weapon.weapon_name).visible = true
	

func _input(event):	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("reload"):
		reload()		
			
#Swap between weapons
	if event.is_action_pressed("slot1"):
		changeWeapon(inventory[0])
		
	if event.is_action_pressed("slot2"):
		changeWeapon(inventory[1])
		
func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * mouse_sensitivity)
			%Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-70), deg_to_rad(70))

func _headbob_effect(delta) -> void:
	headbob_time += delta * self.velocity.length()
	%Camera3D.transform.origin = Vector3(
		cos(headbob_time * headbob_frequency * 0.5) * headbob_shake,
		sin(headbob_time * headbob_frequency * 0.5) * headbob_shake,
		0
	)

func get_move_speed() -> float:
	if Input.is_action_pressed("sprint"):
		return sprint_speed 
	else:
		return walk_speed	

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back").normalized()
	desired_direction = self.global_transform.basis * Vector3(direction.x, 0.0, direction.y)
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			self.velocity.y = jump_strength
		else:
			_floor_physics(delta)
	else:
		_air_physics(delta)
	
	move_and_slide()	

func _floor_physics(delta) -> void:
	var current_speed_in_desired_direction = self.velocity.dot(desired_direction)
	var add_speed_till_cap = get_move_speed() - current_speed_in_desired_direction
	if add_speed_till_cap > 0:
		var accel_speed = ground_speed_acceleration * delta * get_move_speed()
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * desired_direction
	
	# Apply friction
	var grip = max(self.velocity.length(), ground_speed_deceleration)
	var deceleration_from_grip = grip * ground_friction * delta
	var new_speed = max(self.velocity.length() - deceleration_from_grip, 0.0)
	if self.velocity.length() > 0:
		new_speed /= self.velocity.length()
	self.velocity *= new_speed
	
	_headbob_effect(delta)
	
func _air_physics(delta) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	# How fast is the player already moving into the direction they want to go in:
	var current_speed_in_desired_direction = self.velocity.dot(desired_direction)
	# This code allows to to gain momentumn in air like the source engine:
	var capped_speed = min((air_move_speed * desired_direction).length(), air_speed_cap)
	var add_speed_till_cap = capped_speed - current_speed_in_desired_direction
	if add_speed_till_cap > 0:
		var current_acceleration = air_speed_acceleration * air_move_speed * delta
		current_acceleration = min(current_acceleration, add_speed_till_cap)
		self.velocity += current_acceleration * desired_direction
	

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
