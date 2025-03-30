extends Node
class_name HealthComponent

@export var max_health:= 100
var health : float
signal damage_taken

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health

func damage(amount):
	health -= amount
	emit_signal("damage_taken")
	#print('From healthComponent: ',get_parent().name, ' hit and has remaining HP: ', health)
	if get_parent().name == "Player":
		# Play sound 
		get_parent().find_child('AudioPlayer').stream = preload('res://sounds/Player/player_hit.mp3')
		get_parent().find_child('AudioPlayer').play()
		
		if health <= 0:
			get_parent().death_state()
	else:
		if health <= 0:
			GlobalDeathSignals.enemy_died.emit()
			get_parent().queue_free()

func add_max_health(amount):
	print('Applying Bonus health')
	max_health += amount
	health = max_health
	GameScript.player_health = health
	print(GameScript.player_health, health)
