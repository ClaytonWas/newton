extends Node
class_name HealthComponent

@export var max_health:= 100
var health : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health

func damage(amount):
	health -= amount
	print('From healthComponent: ',get_parent().name, ' got hit and dealt ', amount, ' for remaining HP: ', health)
	if health <= 0:
		GlobalDeathSignals.enemy_died.emit()
		get_parent().queue_free()
