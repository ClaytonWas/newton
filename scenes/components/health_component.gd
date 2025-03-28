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
		if health <= 0:
			get_parent().death_state()
	else:
		if health <= 0:
			GlobalDeathSignals.enemy_died.emit()
			get_parent().queue_free()

func add_max_health(amount):
	print('Applying Bonus health')
	self.max_health += amount
	self.health = max_health
