extends Control

# Represents randomizable ability upgrade types
const UPGRADE_TYPES = ['Health', 'Damage', 'Ammo']
const image_path = 'res://textures/guns/pics/'

func _ready() -> void:
	randomize()
	generate_upgrades()		#Chooses 2 randomized upgrades

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_continue_button_button_down() -> void:
	get_tree().change_scene_to_file(GameScript.next_scene())

func _on_quit_button_down() -> void:
	get_tree().quit()

func update_shop_label(upgrade):
	#Generates an upgrade Panel on the UI
	
	var panel = load('res://scenes/UI/shop_upgrade.tscn').instantiate()
	var type_label = panel.find_child('TypeLabel')	#Element variables
	var image = panel.find_child('Image')
	var desc = panel.find_child('Desc')
	var button = panel.find_child('BuyButton')
	
	if (upgrade is Weapon): #Gun upgrade - Choose Random Weapon
		type_label.text = 'New Weapon Upgrade: \t\t%s' % [upgrade.weapon_name]
		desc.text = 'Name: %s \t-\t%s\nBullet Type: %s\nDamage: %d\nAmmo Capacity: %d' % [upgrade.weapon_name,"Full-Auto" if upgrade.is_fullauto else "Semi-Auto", upgrade.bullet_type, upgrade.damage, upgrade.magazine_size]
		image.text = '[img=128x96]%s[/img]' % [image_path + upgrade.weapon_name + '.png']
		#Click listener to add weapon
		button.pressed.connect(self.add_weapon_to_player.bind(upgrade))
		
	else:	#Abilities upgrade
		#Choose random gun
		var gun = GameScript.player_inventory[randi() % GameScript.player_inventory.size()]
		var type
		#Decypher type
		for ability in UPGRADE_TYPES:
			if upgrade.contains(ability):
				type_label.text = ability + ' Upgrade'
				type = ability
		# add gun name to message
		desc.text = upgrade if upgrade.contains('Health') else upgrade + gun.weapon_name
		image.text = '[img=128x96]%s[/img]' % [image_path + type.to_lower() + '_icon.svg']
		print(image_path + upgrade.to_lower() + '_icon.svg')
		button.pressed.connect(self.add_ability_upgrade.bind(upgrade))
	%VBoxUpgrades.add_child(panel)
	
func build_ability_upgrade(ability: String):
	# Builds ability upgrade panel from UPGRADE_TYPE with randomization
	# Returns description message
	var range = [0,0]	#Upper & Lower bounds for randomization variance
	var step = 1	#Step limit for random number (ie. for health step of 5)
	var message = ''
	
	match ability:
		'Health':
			range = [25,75]
			step = 5
			message = 'Player has been granted +%d additional Health Points'
		'Ammo':
			range = [3,10]
			message = 'Player has been granted +%d additional Ammo in the magazine of '
		
		'Damage':
			range = [10,50]
			step = 10
			message = 'Player has been granted +%d additional Damage on '
	
	#Random number between range with step
	var variance = range[0] + (randi() % ((range[1] - range[0]) / step + 1)) * step
	return message % [variance]

func generate_upgrades():
	#Shop offers one new weapon upgrade & one abilities upgrade
	
	#Choose random gun - NOT already owned
	var new_guns = GameScript.GUN_POOL.filter(func(x): return x not in GameScript.player_inventory)	
	var gun_offer = new_guns[randi() % new_guns.size()]
	update_shop_label(gun_offer)
	
	#Choose ability upgrade
	var ability = UPGRADE_TYPES[randi() % UPGRADE_TYPES.size()]
	var ability_offer = build_ability_upgrade(ability)
	update_shop_label(ability_offer)
	
	
func add_weapon_to_player(gun: Weapon):
	#Adds Weapon (WeaponResource.gd) to player_inventory in game_script.gd
	#Connects to gun upgrade 'buy' button
	GameScript.add_weapon(gun)
	
func add_ability_upgrade(ability):
	#Isolate number from message
	var value = float(ability.split('+')[1].substr(0,2))
	
	#Health case
	if ability.contains(UPGRADE_TYPES[0]):
		GameScript.add_health = value
		print('Adding %d HP to player.' % [value])
	
	#Damage Case
	elif ability.contains(UPGRADE_TYPES[1]):
		GameScript.upgrade_damage(value)
		print('Adding %d Damage to %s.' % [value, GameScript.equipped_weapon.weapon_name])
	# Ammo case
	elif ability.contains(UPGRADE_TYPES[2]):
		GameScript.upgrade_ammo(value)
		print('Adding %d bullets to clip of %s.' % [value, GameScript.equipped_weapon.weapon_name])
