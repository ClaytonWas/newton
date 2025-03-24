extends Node3D

var equipped_weapon : Weapon
@onready var inventory: Array[Weapon] = GameScript.player_inventory
var equipped_weapon_node: Node3D
var is_shooting = false
var shot_interval: float = 0.0		#Time elapsed counter for full auto
var can_shoot: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#equipped_weapon = inventory[0]
	#equipped_weapon.mag = equipped_weapon.magazine_size
#
	#equipped_weapon_node = self.find_child(equipped_weapon.weapon_name)
	#equipped_weapon_node.visible = true
	change_weapon(0)

func _input(event):	
	if Input.is_action_pressed("shoot"):
		if equipped_weapon.bullet_type == 'shotgun':	#Fire shotgun
			shoot()
		else:
			shoot()	
			if (equipped_weapon.is_fullauto):	#Manage full auto
				is_shooting = true
			else:
				is_shooting = false
			
	if Input.is_action_just_pressed("reload"):
		reload()		
	
	if Input.is_action_just_released("shoot"):	
		is_shooting = false
		#if (equipped_weapon.is_fullauto):
		#	%AudioPlayer.stop()
#Swap between weapons
	if event.is_action_pressed("slot1"):
		change_weapon(0)
		
	if event.is_action_pressed("slot2"):
		change_weapon(1)
	if event.is_action_pressed("slot3"):
		change_weapon(2)
	if event.is_action_pressed("slot4"):
		change_weapon(3)
	if event.is_action_pressed("slot5"):
		change_weapon(4)
		
func change_weapon(index:int):
	if (index < len(inventory)):
		var gun = inventory[index]
		
		#Hide current weapon
		if equipped_weapon_node:
			equipped_weapon_node.visible = false
		equipped_weapon = gun
		equipped_weapon_node = self.find_child(equipped_weapon.weapon_name)
	
		#Show new weapon
		equipped_weapon_node.visible = true

		if (gun.mag==0):	#Fix guns spawning unloaded
			gun.mag = gun.magazine_size
		
		%ShotTimer.wait_time = gun.fire_rate
		%ShotTimer.timeout.connect(self._on_reload_timer_timeout)
		update_ammo_UI(equipped_weapon.mag)
		print('Switched to ',gun.weapon_name,' dealing ',gun.damage,' per shot.')
	
	

func shoot():
	#Fires one bullet from equipped gun
	if equipped_weapon.mag > 0 and can_shoot and not GameScript.is_sprinting:
		
		equipped_weapon.shoot()		#Updates Weapon ammo 
		update_ammo_UI(equipped_weapon.mag)	#Update UI

		equipped_weapon_node.find_child('muzzle_flash').visible=true	#Show muzzle flash
		equipped_weapon_node.find_child('muzzle_flash').find_child('FlashTimer').start()

		%AudioPlayer.stream = equipped_weapon.fire_sound	#Play sound
		%AudioPlayer.play()
		
		#Animate Player
		%AnimationPlayer.play('shoot')
		
		if equipped_weapon.bullet_type == 'shotgun':		#Shoot shotgun round
			var spread = equipped_weapon.spread
			for i in range (0,equipped_weapon.pellet_count):
				var bullet_offset = Vector3(	#Shotgun spread simulation
									randf_range(-spread, spread),
									randf_range(-spread, spread),
									randf_range(-spread, spread)
								)
				fire_bullet(equipped_weapon, bullet_offset)
		else:	#Fire standard round
			fire_bullet(equipped_weapon, Vector3.ZERO)
	else:
		print("Out of ammo!")
		%AudioPlayer.stream = equipped_weapon.dryfire_sound	#Play dry fire sound
		%AudioPlayer.play()


func reload():
	if (equipped_weapon.mag != equipped_weapon.magazine_size):	#Only reload if clip isnt full
		print(equipped_weapon, equipped_weapon.reload_time)
		# Clip node for visual reload
		var clip = find_child('Clip')
		clip.visible = true
		clip.global_transform = equipped_weapon_node.find_child('clip_spawn').global_transform.basis
		
		
		%AudioPlayer.stream = equipped_weapon.reload_sound	#Play dry fire sound
		%AudioPlayer.play()
		
		can_shoot = false
		# Animate Player
		if (equipped_weapon.bullet_type == 'shotgun'):	#Shotgun reload
			clip.find_child('shotgun').visible = true
			clip.find_child('mag').visible = false
			%AnimationPlayer.play('reload_shotgun')
			
		#Standard reload
		else:
			%AnimationPlayer.play('reload_light')
			#clip.rotation = Vector3(0,0,89)	
			clip.find_child('mag').visible = true
			clip.find_child('shotgun').visible = false
			
		
		var reload_timer = Timer.new()
		add_child(reload_timer)
		reload_timer.wait_time = equipped_weapon.reload_time
		reload_timer.timeout.connect(self._on_reload_timer_timeout)
		reload_timer.start()
		
		
		equipped_weapon.reload()
		update_ammo_UI(equipped_weapon.mag)

func _on_reload_timer_timeout():
	can_shoot = true

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
	
func _physics_process(delta: float) -> void:
	if is_shooting and can_shoot:		# Full auto bullet firing
		# is_shooting is true when 'Fire' button is held down
		%ShotTimer.start()
		shoot()
		can_shoot = false
	
	if (!%AnimationPlayer.is_playing()):
		find_child('Clip').visible = false
	else:
		#Animation playing
		if %AnimationPlayer.current_animation == "sprint" and not GameScript.is_sprinting:
			%AnimationPlayer.play('RESET')
			#pass

func update_ammo_UI(value: int) -> void:
	%HUD.get_node("AmmoLabel").set_text(str(value))

func _process(delta: float) -> void:
	GameScript.equipped_weapon = equipped_weapon

	
