extends Node
class_name HealthComponent

@export var max_health:= 100
var health : float
var player_heal_amount: float = 25	# Amount of health added per heal interval
var heal_timer
signal damage_taken
signal healing
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	
	if get_parent().has_node('HealTimer'):
		heal_timer = get_parent().get_node('HealTimer')
		heal_timer.timeout.connect(heal)
func _process(delta: float) -> void:
	# Heal at time interval
	#if get_parent().name == "Player":
		#if health < max_health and heal_timer:
			##Heal
			#
			#print('timer started')
	pass
func damage(amount):
	health -= amount
	emit_signal("damage_taken")
	#print('From healthComponent: ',get_parent().name, ' hit and has remaining HP: ', health)
	if get_parent().name == "Player":
		# Play sound 
		get_parent().find_child('AudioPlayer').stream = preload('res://sounds/Player/player_hit.mp3')
		get_parent().find_child('AudioPlayer').play()
		
		heal_timer.start()
		
		if health <= 0:
			get_parent().death_state()
	else:
		if health <= 0:
			GlobalDeathSignals.enemy_died.emit()
			get_parent().queue_free()
			
func heal() -> void:
	# Function to apply healing to health variable without exceeding max
	emit_signal("healing")
	health += player_heal_amount
	if health  > max_health:
		health = max_health

func add_max_health(amount):
	print('Applying Bonus health')
	max_health += amount
	health = max_health
	GameScript.player_health = health
	print(GameScript.player_health, health)
