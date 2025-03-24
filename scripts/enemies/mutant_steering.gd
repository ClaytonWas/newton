extends CharacterBody3D

@export var target_node: CharacterBody3D

var is_attacking: bool = false

@onready var agent := await GSAICharacterBody3DAgent.new(self)
@onready var target := GSAIAgentLocation.new()
@onready var accel := GSAITargetAcceleration.new()
@onready var blend := GSAIBlend.new(agent)
@onready var face := GSAIFace.new(agent, target, true)
@onready var arrive := GSAIArrive.new(agent, target)

@onready var anim_tree = self.find_child('AnimationTree')
@onready var anim_state = anim_tree.get("parameters/playback")

func _ready():
	anim_state.travel('mutant_idle')
	
	

func _physics_process(delta: float) -> void:
	target.position = target_node.transform.origin
	target.position.y = transform.origin.y
	blend.calculate_steering(accel)
	agent._apply_steering(accel, delta)
	
	if velocity > Vector3.ZERO:
		anim_state.travel('mutant_run')
		
	if is_attacking:
		velocity = Vector3.ZERO


func setup(
	align_tolerance: float,
	angular_deceleration_radius: float,
	angular_accel_max: float,
	angular_speed_max: float,
	deceleration_radius: float,
	arrival_tolerance: float,
	linear_acceleration_max: float,
	linear_speed_max: float,
	_target: CharacterBody3D
) -> void:
	agent.linear_speed_max = linear_speed_max
	agent.linear_acceleration_max = linear_acceleration_max
	agent.linear_drag_percentage = 0.05
	agent.angular_acceleration_max = angular_accel_max
	agent.angular_speed_max = angular_speed_max
	agent.angular_drag_percentage = 0.1

	arrive.arrival_tolerance = arrival_tolerance
	arrive.deceleration_radius = deceleration_radius

	face.alignment_tolerance = align_tolerance
	face.deceleration_radius = angular_deceleration_radius

	target_node = _target
	self.target.position = target_node.transform.origin
	blend.add(arrive, 1)
	blend.add(face, 1)
	print('Monster is setup for ',target_node.name)

func _on_vision_area_body_entered(body: Node3D) -> void:
	#Prevent vertical movement while running
	#When vision area is entered
	if not is_attacking and body.name == 'Player':
		print('Boss spotted Player')
		anim_state.travel('mutant_run')
		
		

	
func _on_attack_area_body_entered(body: Node3D) -> void:	
	#When attack radius is entered
	if body.name == 'Player': 
		is_attacking = true
		print('Boss attacking')
		anim_state.travel('mutant_punch')


func _on_attack_area_body_exited(body: Node3D) -> void:
	is_attacking = false


func _on_hitbox_component_body_entered(body: Node3D) -> void:
	print('Headshot!') # Replace with function body.


func _on_tree_exiting() -> void:
	# When Boss dies
	GameScript.game_won = true
