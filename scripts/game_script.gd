extends Node

const GUN_POOL = [
	preload('res://resources/old_glock.tres'),
	preload('res://resources/fade_glock.tres'),
	preload('res://resources/laser_gun.tres'),
	preload('res://resources/mac10.tres'),
	preload('res://resources/shotgun.tres')
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

# Settings screen variables
var hardcore: bool = false
var music: bool = true

# Game Timer variables
var timer_time: float
var score: int = 0 # Players score/currency for shop
var level_counter: int = 0	# Counts how many levels player completed

var level_order : Array[String] #Ordered list: First-In-First-Out & iterated through by array.pop() 
var skip_tutorial: bool = false # Flag to show tutorial UI
var player_inventory: Array[Weapon] 
var equipped_weapon: Weapon # Tracks current equipped weapon
var add_health: float = 0.0	# Flag Variable to add HP based on ability booster - checked in playermovement.gd
var is_sprinting: bool = false	# Tracks if player is sprinting
var game_won: bool	# Global won game flag

func start_game():
	#Resets variables for fresh game runs
	randomize()
	player_inventory = [GUN_POOL[0]]	#Set starting weapon
	equipped_weapon= player_inventory[0]
	level_order = [LEVELS[0], LEVELS[1], LEVELS[4],LEVELS[3]]
	game_won = false
	
func _ready() -> void:
	start_game()
	# Play music
	if music:
		add_child(musicPlayer)
		musicPlayer.stream = preload('res://sounds/Music/video-game-music-147338.mp3')
		play_music()

func _process(delta: float) -> void:
	#Disable music
	if not music:
		musicPlayer.stop()

	else:	# Update volume
		play_music()

func next_scene():
	#Function to return the next scene in layout order & pop from list
	var temp = level_order[0]
	level_counter += 1
	level_order.pop_front()
	Engine.time_scale = 1.0
	musicPlayer.stop()
	return temp

func add_weapon(gun: Weapon) -> void:
	if not gun in player_inventory:
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
	if music and not musicPlayer.is_playing():
		if get_tree().current_scene:
			if get_tree().current_scene.scene_file_path.contains('shop') or get_tree().current_scene.scene_file_path.contains('start_menu'):
				musicPlayer.play()

func set_volume(value: float) -> void:
	# Alters volume of audio buses
	print("setting audio to ",value, linear_to_db(value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear_to_db(value))

func calculate_score() -> int:
	# Save time left on game clock
	print(timer_time, score, ' time left')
	var point_interval = 300
	var time_interval = 15
	# Formula to give {point_interval} points per {time_interval} seconds left
	score += floor(timer_time / time_interval) * point_interval
	print('Calculating score of ',score, timer_time)
	
	return score
