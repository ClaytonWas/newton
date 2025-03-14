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
		
		var raycast =  %RayCast3D
		var hit_object = raycast.get_collider()
		var hit_point = raycast.get_collision_point()
		
		if hit_object:
			if hit_object.has_node("HitboxComponent"):
				var hitbox : HitboxComponent = hit_object.find_child("HitboxComponent")
				var amount = equipped_weapon.damage
				hitbox.damage(amount)
			else:
				print(hit_object.name)
	
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
