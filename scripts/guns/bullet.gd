extends Node3D

@export var speed = 20.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(-speed,0, 0) * delta 


func _on_timer_timeout() -> void:
	queue_free()


func _on_hitbox_component_body_entered(body: Node3D) -> void:
	print(self.name, ' bullet hit ', body.name)
	queue_free()
