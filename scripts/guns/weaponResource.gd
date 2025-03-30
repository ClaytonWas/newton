class_name Weapon extends Resource

@export var weapon_name : StringName

@export_category("Visual & Audio Settings")
@export var fire_sound: AudioStream
@export var reload_sound: AudioStream
@export var dryfire_sound:  AudioStream = preload('res://sounds/Guns/shot_dry.wav')
@export var mesh: Mesh

@export_category("Weapon Stats")
@export var bullet_type = 'light'
@export var damage: float
@export var magazine_size: int	#maxmimum amount of bullets weapon can load

@export var reload_time: float = 1	#Timer duration
@export var is_melee: bool = false
@export var is_fullauto: bool 
@export var fire_rate: float
@export_category('Shotgun Options')
@export var pellet_count: int	#Number of pellets to be fired
@export var spread: float	#Bullet displacement

var is_reloading: bool = false	#Flag to avoid reload spam
var mag: int = magazine_size	#Current amount of bullets loaded

func _init():
	mag = magazine_size

func get_damage():return damage
func update_ammo(shots: int = 0):
	#This function is used when the magazine capacity changes
	#Negative numbers when decrementing (shooting)
	# Positive numbers when reloading
	#Reloading in character controller would look like this:
	#gun.update_ammo
	
	if (mag + shots) >= 0 and (mag + shots <= magazine_size):	#Avoid negative bullets and overloading
		mag += shots


func shoot(): update_ammo(-1)			#Function to manage magazine size when shooting

func reload(): 
	print("Reloading...")
	print("Current Ammo: ", mag, "/")
	update_ammo(magazine_size - mag) #Function to manage magazine size when reloading
	print('Reload Complete Mag:',mag, '/')
