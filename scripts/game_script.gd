extends Node
const VOLUME_LIMIT_DB = -25.0	# Music volume cap
const max_inv_size: int = 3	# Max amount of guns player can carry
var gun_paths = {
	'old_glock': 'res://resources/old_glock.tres',
	'fade_glock': 'res://resources/fade_glock.tres',
	'Mac10':'res://resources/mac10.tres',
	'LaserGun': 'res://resources/laser_gun.tres',
	'Shotgun': 'res://resources/shotgun.tres'
}

var GUN_POOL = [
	load('res://resources/old_glock.tres').duplicate(),
	load('res://resources/fade_glock.tres').duplicate(),
	load('res://resources/laser_gun.tres').duplicate(),
	load('res://resources/mac10.tres').duplicate(),
	load('res://resources/shotgun.tres').duplicate()
]

const LEVELS =  [		#Names of level scenes as navigation path 
	'res://scenes/levels/outdoors.tscn',
	'res://scenes/levels/main.tscn',
	'res://scenes/levels/mines.tscn',
	'res://scenes/levels/nether.tscn',
	'res://scenes/levels/sewers/main.tscn'
]
# Game music audioplayer
@onready var musicPlayer = AudioStreamPlayer.new()
var music_sound = preload('res://sounds/Music/video-game-music-147338.mp3')
var countdown_sound = preload('res://sounds/Music/10sec-digital-countdown.wav')
var win_music = preload('res://sounds/Music/win_music.mp3')

# Settings screen variables
var hardcore: bool = false
var music: bool = true
var sensitivity : float = 0.002	# Default mouse sensitivity
# Game Timer variables
var timer_time: float
var score: int	# Players score/currency for shop
var level_counter: int # Counts how many levels player completed

var level_order : Array[String] #Ordered list: First-In-First-Out & iterated through by array.pop() 
var skip_tutorial: bool = false # Flag to show tutorial UI
var player_inventory: Array
var equipped_weapon: Weapon # Tracks current equipped weapon
var player_health: float  # Tracks value in player HealthComponent
var add_health: float = 0.0	# Flag Variable to add HP based on ability booster - checked in playermovement.gd
var is_sprinting: bool = false	# Tracks if player is sprinting
var game_won: bool	# Global won game flag

func start_game():
	#Resets variables for fresh game runs
	randomize()
	player_inventory = [GUN_POOL[0]]	#Set starting weapon
	player_health = preload('res://scenes/player.tscn').instantiate().find_child('HealthComponent').max_health# default value before scene enters
	equipped_weapon= player_inventory[0]


	level_order = [LEVELS[0], LEVELS[1], LEVELS[4], LEVELS[3]] 


	game_won = false
	score = 0
	level_counter = 0
	
	
func _ready() -> void:
	start_game()
	# Play music
	if music:
		add_child(musicPlayer)
		musicPlayer.stream = music_sound
		play_music()

func _process(delta: float) -> void:
	#Disable music
	if not music:
		musicPlayer.stop()

	else:	# Update volume
		play_music()
		
	# 10 Second timer
	if get_tree().current_scene:
		if get_tree().current_scene.scene_file_path in LEVELS:
			if timer_time <= 10 and not musicPlayer.is_playing():
				print('countdown on')
				musicPlayer.stream = countdown_sound
				musicPlayer.play()
		
func next_scene():
	#Function to return the next scene in layout order & pop from list
	var temp = level_order[0]
	level_counter += 1
	level_order.pop_front()
	Engine.time_scale = 1.0
	musicPlayer.stop()
	return temp

func add_weapon(gun: Weapon) -> void:
	if not gun in player_inventory: 	#If gun doesnt exist in inventory
		if not player_inventory.size() >= max_inv_size:	# max inv size
			player_inventory.append(gun)

func upgrade_damage(damage: float) -> void:
	# Applies weapon upgrade globally
	equipped_weapon.damage += damage
	#Update inventory list
	player_inventory[player_inventory.find(equipped_weapon)] = equipped_weapon
	
func upgrade_ammo(ammo: float) -> void:
	# Applies magazine upgrade globally
	equipped_weapon.magazine_size += ammo
	#Update inventory list
	player_inventory[player_inventory.find(equipped_weapon)] = equipped_weapon

func settings_toggle(setting: String):
	# Toggles settings booleans
	if setting == 'hardcore':
		hardcore = !hardcore
	
	elif setting == 'music':
		music = !music
		print('music off')

func play_music():
	# Starts the audio stream
	if music and (not musicPlayer.is_playing() or musicPlayer.stream == countdown_sound):
		if get_tree().current_scene:
			if get_tree().current_scene.scene_file_path.contains('shop') or get_tree().current_scene.scene_file_path.contains('start_menu'):
				musicPlayer.play()
				musicPlayer.volume_db = min(musicPlayer.volume_db, VOLUME_LIMIT_DB)
func set_volume(value: float) -> void:
	# Alters volume of audio buses
	print("setting audio to ",value, linear_to_db(value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear_to_db(value))

func calculate_score() -> int:
	# Save time left on game clock
	var point_interval = 750
	var time_interval = 10
	# Formula to give {point_interval} points per {time_interval} seconds left
	score += floor(timer_time / time_interval) * point_interval
	
	return score

func on_restart():

	# Called when restarted
	# Swap player inventory for default guns @ index
	var temp = player_inventory
	for weapon in player_inventory:
		var fresh_weapon = load(gun_paths[weapon.weapon_name]).duplicate() as Weapon
		#temp.append(fresh_weapon)  # Add the fresh weapon to the temp list
		print('Reloading %s with stats of %d %d' % [fresh_weapon.weapon_name, fresh_weapon.damage,fresh_weapon.magazine_size])
		weapon.damage = fresh_weapon.damage
		weapon.magazine_size = fresh_weapon.magazine_size
	player_inventory = temp  # Replace the original list
	score = 0
	get_tree().change_scene_to_file("res://scenes/levels/start_menu.tscn")
