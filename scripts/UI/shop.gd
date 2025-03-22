extends Control


func _ready() -> void:
	randomize()
	print(GameScript.GUN_POOL)
	generate_upgrades()		#Chooses 2 randomized upgrades

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_continue_button_button_down() -> void:
	get_tree().change_scene_to_file(GameScript.next_scene())


func _on_quit_button_down() -> void:
	get_tree().quit()

func update_shop_label(upgrade):
	var panel = load('res://scenes/UI/shop_upgrade.tscn').instantiate()
	var type_label = panel.find_child('TypeLabel')	#Element variables
	var image = panel.find_child('Image')
	var desc = panel.find_child('Desc')
	print('offer type is ', typeof(upgrade))
	if (upgrade is Weapon): #Gun upgrade - Choose Random Weapon
		type_label.text = 'New Weapon Upgrade: \t\t%s' % [upgrade.weapon_name]
		desc.text = 'Name: %s \t-\t%s\nBullet Type: %s\nDamage: %d\nAmmo Capacity: %d' % [upgrade.weapon_name,"Full-Auto" if upgrade.is_fullauto else "Semi-Auto", upgrade.bullet_type, upgrade.damage, upgrade.magazine_size]
		
	else:	#Abilities upgrade
		type_label.text = 'Damage Upgrade'
		
	%VBoxUpgrades.add_child(panel)
	
func generate_upgrades():
	#Shop offers one new weapon upgrade & one abilities upgrade
	#Weapon upgrade
	var weapon_upgrade
	
	#Choose new gun
	var new_guns = GameScript.GUN_POOL.filter(func(x): return x not in GameScript.player_inventory)
	print(new_guns)
	
	var offer = new_guns[randi() % new_guns.size()]
	print(offer.weapon_name)
	
	update_shop_label(offer)
	
	
