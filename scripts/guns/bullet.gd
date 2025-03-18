extends Node3D

@export var speed = 20.0
var offset: Vector3		# Values to offset shotgun bullets
var damage:int	#Damage value to be set from Player_shoot script

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
	print(self.name, ' bullet hit ', body.name)
	queue_free()
	
	if body.has_node("HitboxComponent"): #Change for attack component?
		var hitbox : HitboxComponent = body.find_child("HitboxComponent")
		hitbox.damage(damage)


func _on_hitbox_component_area_entered(area: Area3D) -> void:
	print(self.name, ' bullet hit in area', area.name)
	if 'HitboxComponent' in area.name:
		area.damage(damage)
