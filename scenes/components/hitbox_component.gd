extends Area3D
class_name HitboxComponent

@export var health_component : HealthComponent

func damage(amount):
	if health_component:
		health_component.damage(amount)
