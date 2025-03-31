extends Node3D

@export var speed = 20.0
var offset: Vector3		# Values to offset shotgun bullets
var damage: int	#Damage value to be set from Player_shoot script
var is_enemy_bullet: bool = false #Toggle to be enabled in enemies bullet scripts when instanited.

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if (offset):	# Fires shotgun spread
		position += transform.basis * (offset + Vector3(-speed,0,0)) * delta 
	else:	# Normal bullet
		position += transform.basis * Vector3(-speed,0,0) * delta 

func _on_timer_timeout() -> void:
	queue_free()

func _on_hitbox_component_body_entered(body: Node3D) -> void:	
	# Player shot by enemy
	if is_enemy_bullet and body.name == "Player":
		if body.has_node("HitboxComponent"):
			print('Player took %d damage!' % [damage])
			var hitbox : HitboxComponent = body.find_child("HitboxComponent")
			hitbox.damage(damage)
			queue_free()
			
func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent and not is_enemy_bullet:
		if area.get_parent().name == "Player":
			pass
		else: # Shot enemy
			if not area.get_parent() is RigidBody3D: #Dont collide with  other bullets
				area.damage(damage)
				queue_free()
