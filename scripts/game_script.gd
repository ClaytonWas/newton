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
	'res://scenes/levels/nether.tscn'
]

#Ordered list: First-In-First-Out & iterated through by array.pop() 
var level_order : Array[String]
var skip_tutorial: bool = false	# Flag to show tutorial UI
var player_inventory: Array[Weapon] 
var equipped_weapon: Weapon # Tracks current equipped weapon
var add_health: float = 0.0	# Flag Variable to add HP based on ability booster - checked in playermovement.gd
var is_sprinting: bool = false	# Tracks if player is sprinting
var game_won: bool	# Global won game flag

func start_game():
	#Resets variables for fresh game runs
	randomize()
	player_inventory = [GUN_POOL[0], GUN_POOL[2], GUN_POOL[3]]	#Set starting weapon
	equipped_weapon= player_inventory[0]
	level_order = [LEVELS[0], LEVELS[1], LEVELS[3]]
	game_won = false
	
func _ready() -> void:
	start_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func next_scene():
	#Function to return the next scene in layout order & pop from list
	var temp = level_order[0]
	level_order.pop_front()
	Engine.time_scale = 1.0
	return temp

func add_weapon(gun: Weapon) -> void:
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

#Tutorial Display Functions
