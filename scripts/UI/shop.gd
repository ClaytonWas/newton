extends Control

# Represents randomizable ability upgrade types
const UPGRADE_TYPES = ['Health', 'Damage', 'Ammo']	
const image_path = 'res://textures/guns/pics/'
var ability_type: String	#Tracks randomly chosen ability
var chosen_gun: Weapon	# Tracks gun to apply upgrades to
var price: int # Cost of upgrade

#Sounds
var normal_click = preload('res://sounds/UI/ui_normal_click.mp3')
var error_click = preload('res://sounds/UI/ui_menu_rejected.mp3')
var buy_click = preload('res://sounds/UI/ui_buy.mp3')

func _ready() -> void:
	randomize()
	generate_inventory_panel()
	generate_upgrades()		#Chooses 2 randomized upgrades
	update_score(GameScript.calculate_score())
	%HealthLabel.text = 'HEALTH: %d' % GameScript.player_health

func update_shop_label(upgrade, inv=false):
	#Inv is boolean flag for inventory panel : hide button
	#Generates an upgrade Panel on the UI
	var panel = load('res://scenes/UI/shop_upgrade.tscn').instantiate()
	var type_label = panel.find_child('TypeLabel')	#Element variables
	var image = panel.find_child('Image')
	var desc = panel.find_child('Desc')
	var button = panel.find_child('BuyButton')
	var remove_button = panel.find_child('RemoveButton')
	
	price = round((750 * GameScript.level_counter)/50) * 50
	
	if (upgrade is Weapon): #Gun upgrade - Choose Random Weapon
		type_label.text = 'New Weapon Upgrade: \t\t%s' % [upgrade.weapon_name]
		desc.text = 'Name: %s \t-\t%s\nBullet Type: %s\nDamage: %d\nAmmo Capacity: %d' % [upgrade.weapon_name,"Full-Auto" if upgrade.is_fullauto else "Semi-Auto", upgrade.bullet_type, upgrade.damage, upgrade.magazine_size]
		image.text = '[img=128x96]%s[/img]' % [image_path + upgrade.weapon_name + '.png']
		#Click listener to add weapon
		button.pressed.connect(self.add_weapon_to_player.bind(upgrade))
		
	else:	#Abilities upgrade
		# #Choose random gun
		var gun = GameScript.equipped_weapon

		#Decypher type
		for ability in UPGRADE_TYPES:
			if upgrade.contains(ability):
				type_label.text = ability + ' Upgrade'
				ability_type = ability	# Global variable
		# add gun name to message
		desc.text = upgrade if upgrade.contains('Health') else upgrade + gun.weapon_name
		image.text = '[img=128x96]%s[/img]' % [image_path + ability_type.to_lower() + '_icon.svg']
		button.pressed.connect(self.add_ability_upgrade.bind(upgrade))
		
	if inv:	# Disables buy button on inventory panels
		button.visible = false
		type_label.text = upgrade.weapon_name
		type_label.add_theme_color_override('default_color', Color.WHITE)
		remove_button.visible = false if GameScript.player_inventory.size() == 1 else true
		remove_button.pressed.connect(self.remove_weapon_inventory.bind(upgrade))
		%InventoryList.add_child(panel)
	else:
		remove_button.visible = false
		button.text = 'BUY: %d' % [price]
		%VBoxUpgrades.add_child(panel)
	
func build_ability_upgrade(ability: String) -> String:
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
	if new_guns:
		var gun_offer = new_guns[randi() % new_guns.size()]
		update_shop_label(gun_offer)
	
	#Choose ability upgrade
	var ability = UPGRADE_TYPES[randi() % UPGRADE_TYPES.size()]
	var ability_offer = build_ability_upgrade(ability)
	update_shop_label(ability_offer)
	
func add_weapon_to_player(gun: Weapon):
	#Adds Weapon (WeaponResource.gd) to player_inventory in game_script.gd
	#Called when Buy Button on gun upgrade is clicked
	if GameScript.score >= price and GameScript.player_inventory.size() + 1 <= GameScript.max_inv_size:
		GameScript.score -= price
		update_score(GameScript.score)
		%AudioPlayer.stream = buy_click
		%AudioPlayer.play()
		GameScript.add_weapon(gun)
		update_confirm_message('%s PURCHASED' % [gun.weapon_name.to_upper()])
		#Update inventory list
		generate_inventory_panel()
		# Remove first child from Upgrades panel
		%VBoxUpgrades.get_child(0).queue_free()
		%VBoxUpgrades.size.y /= 2
		
		#Update UI
		generate_inventory_panel()
	else:	# Rejected buy
		%AudioPlayer.stream = error_click
		%AudioPlayer.play()
	
func add_ability_upgrade(ability):
	# Applies ability to player
	#Called when Buy Button on ability upgrade is clicked
	
	if GameScript.score >= price:
		GameScript.score -= price
		%AudioPlayer.stream = buy_click
		%AudioPlayer.play()
		update_score(GameScript.score)
		var value = float(ability.split('+')[1].substr(0,2))	#Isolate number from message
		
		#Health case
		if ability.contains("Health"):
			GameScript.add_health = value
			print('Adding %d HP to player.' % [value])
			%HealthLabel.text = 'HEALTH: %d' % [GameScript.player_health + value]
		#Damage Case
		elif ability.contains("Damage"):
			GameScript.upgrade_damage(value)
			print('Adding %d Damage to %s.' % [value, GameScript.equipped_weapon.weapon_name])
		# Ammo case
		elif ability.contains("Ammo"):
			GameScript.upgrade_ammo(value)
			print('Adding %d bullets to clip of %s.' % [value, GameScript.equipped_weapon.weapon_name])

		update_confirm_message('%s UPGRADE PURCHASED' % [ability_type.to_upper()])
		# Remove last child from Upgrades panel
		%VBoxUpgrades.get_child(%VBoxUpgrades.get_children().size()-1).queue_free()
		%VBoxUpgrades.size.y /= 2
		generate_inventory_panel()
		
	else:	# Rejected buy
		%AudioPlayer.stream = error_click
		%AudioPlayer.play()
		
func update_confirm_message(message: String) -> void:
	#Updates confirmation message on UI
	if %ConfirmMessage:
		%ConfirmMessage.text = message
func update_score(value: int) -> void:
	# Updates score label
	%Score.text = '[img]res://textures/general/coin.svg[/img]:   %d' % [value]

func generate_inventory_panel():
	#Clear old panels
	for child in %InventoryList.get_children(): %InventoryList.remove_child(child)

	# Make panels for each gun in inventory section
	for weapon in GameScript.player_inventory:
		update_shop_label(weapon, true)

func _on_back_button_pressed() -> void:
	GameScript.on_restart()
	#get_tree().change_scene_to_file('res://scenes/levels/start_menu.tscn')
	
func _on_tree_entered() -> void:
	# Start music player
	GameScript.play_music()

func _on_continue_button_button_down() -> void:
	# Continue to next level
	%AudioPlayer.stream = normal_click
	%AudioPlayer.play()
	get_tree().change_scene_to_file(GameScript.next_scene())

func remove_weapon_inventory(gun: Weapon):
	# Removes weapon from player inventory
	if gun in GameScript.player_inventory and GameScript.player_inventory.size() > 1:
		%InventoryList.get_child(GameScript.player_inventory.find(gun)).queue_free()# Remove UI panel
		GameScript.player_inventory.remove_at(GameScript.player_inventory.find(gun)) # Remove from global list
	generate_inventory_panel()
	
func _on_quit_button_down() -> void:
	get_tree().quit()
