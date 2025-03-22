extends Node

const GUN_POOL = [
	preload('res://resources/old_glock.tres'),
	preload('res://resources/fade_glock.tres'),
	preload('res://resources/laser_gun.tres'),
	preload('res://resources/mac10.tres'),
	preload('res://resources/shotgun.tres')
]

const LEVELS =  [
	'res://scenes/levels/outdoors.tscn',
	'res://scenes/levels/main.tscn',
	'res://scenes/levels/mines.tscn',
	'res://scenes/levels/nether.tscn'
]

var level_order = [LEVELS[0], LEVELS[1], LEVELS[3]]

var player_inventory: Array[Weapon] = [GUN_POOL[0]]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func next_scene():
	#Function to return the next scene in layout order & pop from list
	var temp = level_order[0]
	level_order.pop_front()
	return temp
