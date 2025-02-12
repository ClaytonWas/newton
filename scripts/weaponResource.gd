class_name Weapon extends Resource

@export var weapon_name : StringName

@export_category("Visual & Audio Settings")
@export var fire_sound: AudioStream
@export var reload_sound: AudioStream
@export var dryfire_sound:  AudioStream
@export var mesh: Mesh

@export_category("Weapon Stats")
@export var damage: float
@export var magazine_size: int	#maxmimum amount of bullets weapon can load
@export var reserve_ammo: int		#Amount of ammo in storage 
@export var reload_time: float = 1	#Timer duration
@export var spread: float	#Bloom multiplier
@export var is_melee: bool = false
@export var is_fullauto: bool 
var is_reloading: bool = false	#Flag to avoid reload spam
var mag: int = magazine_size	#Current amount of bullets loaded

func _ready():
	reserve_ammo += magazine_size
	update_ammo(magazine_size)


func get_damage():return damage
func update_ammo(shots: int = 0):
	#This function is used when the magazine capacity changes
	#Negative numbers when decrementing (shooting)
	# Positive numbers when reloading
	#Reloading in character controller would look like this:
	#gun.update_ammo
	
	if (mag + shots) >= 0 and (mag + shots <= magazine_size):	#Avoid negative bullets and overloading
		mag += shots
		
		if shots > 0:
			#Positve numbers mean reloading, decrement reserve ammo
			reserve_ammo -= shots
			
			#If reserve ammo is now negative, we reloaded more than available. Undo this behaviour
			if reserve_ammo < 0:
				mag += reserve_ammo		#Take out the overdraft bullets
				reserve_ammo = 0 

func shoot(): update_ammo(-1)			#Function to manage magazine size when shooting

func reload(): 
	print("Reloading...")
	print("Current Ammo: ", mag, "/", reserve_ammo)
	update_ammo(magazine_size - mag) #Function to manage magazine size when reloading
	print('Reload Complete Mag:',mag, '/', reserve_ammo)
