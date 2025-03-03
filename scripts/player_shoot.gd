extends Node3D

@export_category("Weapon Variables")
@export var inventory: Array[Weapon] = []
@export var equipped_weapon : Weapon
var equipped_weapon_node: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	equipped_weapon = inventory[0]
	
	var gun_node = load("res://scenes/guns/" + equipped_weapon.weapon_name + ".tscn")

	equipped_weapon_node = self.find_child(equipped_weapon.weapon_name)
	equipped_weapon_node.visible = true

func _input(event):	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("reload"):
		reload()		
			
#Swap between weapons
	if event.is_action_pressed("slot1"):
		change_weapon(inventory[0])
		
	if event.is_action_pressed("slot2"):
		change_weapon(inventory[1])
	if event.is_action_pressed("slot3"):
		change_weapon(inventory[2])
		
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

	#%right_hand.find_child(old_gun.weapon_name).visible = false
	#%right_hand.find_child(equipped_weapon.weapon_name).visible = true
	print('Switched to ',gun.weapon_name,' dealing ',gun.damage,' per shot.')

func shoot():
	if equipped_weapon.mag > 0:
		print("Shooting from ",equipped_weapon.weapon_name)
		
		equipped_weapon.shoot()		#Handles ammo count

		equipped_weapon_node.find_child('muzzle_flash').visible=true	#Show muzzle flash
		equipped_weapon_node.find_child('muzzle_flash').find_child('FlashTimer').start()
		
		print(equipped_weapon.dryfire_sound, equipped_weapon.fire_sound)
		%AudioPlayer.stream = equipped_weapon.fire_sound	#Play sound
		%AudioPlayer.play()
		
		var raycast =  self.get_parent_node_3d().find_child("Camera3D").find_child("RayCast3D")
		var hit_object = raycast.get_collider()
		var hit_point = raycast.get_collision_point()
		
		if raycast.is_colliding():
			if "Demon" in hit_object.name:
				print("Hit: ", hit_object.name)
				hit_object.takeDamage(equipped_weapon.damage)
				
			elif "Physical Bone" in hit_object.name:	#Shot Boss
				var root = hit_object.get_parent()  # Get the immediate parent
				while root and not root is CharacterBody3D:  
					root = root.get_parent()  
				print('Hit Boss ', root.name)
				root.take_damage(equipped_weapon.damage)
			else:
				#Spawn bullet hole
				var bullet_hole = load("res://scenes/guns/bullet_hole.tscn").instantiate()
				#bullet_hole.global_transform.origin = hit_point.position
				
				#hit_object.add_child_scene(bullet_hole)
				print('Missed, hit instead: ', hit_object, hit_point)
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
