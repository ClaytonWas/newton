extends Node3D

@export var clock_axis: Node3D
@onready var timer: Timer = %Timer

#@onready var label: MeshInstance3D = self.find_child('Center').find_child('TimeLeft')	# Clock label
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	clock_axis.rotation.z = rotate_hand()
	#label.mesh.text =str(round(timer.time_left))
	
func rotate_hand():
	# Calculate angle based on elapsed time within a 60-second cycle
	var elapsed_time = 60 - timer.get_time_left()
	var angle = deg_to_rad(elapsed_time * 6.0)  # 360° / 60 seconds = 6° per second
	
	return angle
