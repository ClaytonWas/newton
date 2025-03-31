extends Node3D

@export var speed = 20.0
var offset: Vector3		# Values to offset shotgun bullets
var damage: int	#Damage value to be set from Player_shoot script
var is_enemy_bullet: bool = false #Toggle to be enabled in enemies bullet scripts when instanited.

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (offset):
		position += transform.basis * (offset + Vector3(-speed,0,0)) * delta 
	else:
		position += transform.basis * Vector3(-speed,0,0) * delta 
	#position += global_position.lerp(direction, speed * delta)
	#position += direction * speed * delta
	

func _on_timer_timeout() -> void:
	queue_free()


func _on_hitbox_component_body_entered(body: Node3D) -> void:	
	if is_enemy_bullet and body.name == "Player":
		print('Enemy bullet hit player!')
		if body.has_node("HitboxComponent"):
			print('Player took %d damage!' % [damage])
			var hitbox : HitboxComponent = body.find_child("HitboxComponent")
			hitbox.damage(damage)
			queue_free()

	if is_enemy_bullet and body.name == "MutantBoss":	
		if body.has_node("HitboxComponent"):
			print('Boss took %d damage!' % [damage])
			var hitbox : HitboxComponent = body.find_child("HitboxComponent")
			hitbox.damage(damage)
			
func _on_hitbox_component_area_entered(area):
	if area is HitboxComponent and not is_enemy_bullet:
		if area.get_parent().name == "Player":
			pass
		else:
			var hitbox = area
			hitbox.damage(damage)
			print('Area hit')
		queue_free()
	#else:
		#print(area.name)
