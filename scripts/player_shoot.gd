extends Node3D

@export_category("Weapon Variables")
@export var inventory: Array[Weapon] = []
@export var equipped_weapon : Weapon
var equipped_weapon_node: Node3D
var is_shooting = false
var shot_interval: float = 0.0		#Time elapsed counter for full auto

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	equipped_weapon = inventory[0]
	equipped_weapon.mag = equipped_weapon.magazine_size
	
	#var gun_node = load("res://scenes/guns/" + equipped_weapon.weapon_name + ".tscn")

	equipped_weapon_node = self.find_child(equipped_weapon.weapon_name)
	equipped_weapon_node.visible = true

func _input(event):	
	if Input.is_action_pressed("shoot"):
		if equipped_weapon.bullet_type == 'shotgun':	#Fire shotgun
			shoot()
		else:
			shoot()	
			if (equipped_weapon.is_fullauto):	#Manage full auto
				is_shooting = true
			
	if Input.is_action_just_pressed("reload"):
		reload()		
	
	if Input.is_action_just_released("shoot"):	
		is_shooting = false
		#if (equipped_weapon.is_fullauto):
		#	%AudioPlayer.stop()
#Swap between weapons
	if event.is_action_pressed("slot1"):
		change_weapon(inventory[0])
		
	if event.is_action_pressed("slot2"):
		change_weapon(inventory[1])
	if event.is_action_pressed("slot3"):
		change_weapon(inventory[2])
	if event.is_action_pressed("slot4"):
		change_weapon(inventory[3])
	if event.is_action_pressed("slot5"):
		change_weapon(inventory[4])
		
func change_weapon(gun:Weapon):
	#Hide current weapon
	var old_gun = equipped_weapon
	equipped_weapon_node.visible = false
		
	equipped_weapon = gun
	equipped_weapon_node = self.find_child(equipped_weapon.weapon_name)
	
	#Show new weapon
	#Jank Code, need to either replace one node OR create new one
	equipped_weapon_node.visible = true
	var gun_node = load("res://scenes/guns/" + gun.weapon_name + ".tscn")

	if (gun.mag==0):	#Fix guns spawning unloaded
		gun.mag = gun.magazine_size
	print('Switched to ',gun.weapon_name,' dealing ',gun.damage,' per shot.')

func shoot():
	#Fires one bullet from equipped gun
	if equipped_weapon.mag > 0:
		print("Shooting from ",equipped_weapon.weapon_name)
		
		equipped_weapon.shoot()		#Handles ammo count

		equipped_weapon_node.find_child('muzzle_flash').visible=true	#Show muzzle flash
		equipped_weapon_node.find_child('muzzle_flash').find_child('FlashTimer').start()

		%AudioPlayer.stream = equipped_weapon.fire_sound	#Play sound
		%AudioPlayer.play()
		
		if equipped_weapon.bullet_type == 'shotgun':
			var spread = equipped_weapon.spread
			for i in range (0,equipped_weapon.pellet_count):
				var bullet_offset = Vector3(	#Shotgun spread simulation
									randf_range(-spread, spread),
									randf_range(-spread, spread),
									randf_range(-spread, spread)
								)
				fire_bullet(equipped_weapon, bullet_offset)
		else:
			fire_bullet(equipped_weapon, Vector3.ZERO)
	else:
		print("Out of ammo!")
		%AudioPlayer.stream = equipped_weapon.dryfire_sound	#Play dry fire sound
		%AudioPlayer.play()

func reload():
	if (equipped_weapon.mag != equipped_weapon.magazine_size):	#Only reload if clip isnt full
		print(equipped_weapon, equipped_weapon.reload_time)
		
		%AudioPlayer.stream = equipped_weapon.reload_sound	#Play dry fire sound
		%AudioPlayer.play()
		
		var timer = Timer.new()
		self.add_child(timer)
		timer.wait_time = equipped_weapon.reload_time
		timer.start()
		
		equipped_weapon.reload()

func fire_bullet(gun, offset):
	# Intakes Weapon resource and global position as params
	# Instantiates a bullet
	# Params: gun : Weapon, offset : Vector3 - bullet offset
	var bullet
	
	if (gun.bullet_type == 'light'):
		bullet = load('res://scenes/guns/bullet.tscn')
	
	elif (gun.bullet_type == 'laser'):
		bullet = load('res://scenes/guns/laser_bullet.tscn')

	if (gun.bullet_type == 'shotgun'):
		bullet = load('res://scenes/guns/pellet.tscn')
	
	var projectile = bullet.instantiate()

	projectile.damage = equipped_weapon.get_damage()
	projectile.offset = offset
	projectile.position = equipped_weapon_node.find_child('bullet_spawn').global_position
	projectile.transform.basis = equipped_weapon_node.find_child('bullet_spawn').global_transform.basis

	#self is right_hand
	get_parent().get_parent().get_parent().get_parent().add_child(projectile) #Add to world screen
	
func _process(delta: float) -> void:
	if is_shooting:		# Full auto bullet firing
		shot_interval += delta
	
		if shot_interval >= equipped_weapon.fire_rate:
			shot_interval = 0.0  # Reset timer
			shoot()
