extends Control

# Represents randomizable ability upgrade types
const UPGRADE_TYPES = ['Health', 'Damage', 'Ammo']

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
	
	if (upgrade is Weapon): #Gun upgrade - Choose Random Weapon
		type_label.text = 'New Weapon Upgrade: \t\t%s' % [upgrade.weapon_name]
		desc.text = 'Name: %s \t-\t%s\nBullet Type: %s\nDamage: %d\nAmmo Capacity: %d' % [upgrade.weapon_name,"Full-Auto" if upgrade.is_fullauto else "Semi-Auto", upgrade.bullet_type, upgrade.damage, upgrade.magazine_size]
		#Click listener to add weapon
		#.connect("pressed", self, "add_weapon_to_player").bind(upgrade)
		print('DEBUG: ',panel.get_node("BuyButton"))
		
	else:	#Abilities upgrade
		var found = UPGRADE_TYPES.find(func(x): return upgrade.has(x))
		type_label.text = UPGRADE_TYPES[found] + ' Upgrade'
		
		desc.text = upgrade # add gun name
	
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
	GameScript.add_weapon(gun)
	
func add_ability_upgrade(ability):
	pass
