extends CharacterBody3D

enum State {
	IDLE,
	ALERTED,
	CHASING,
	ATTACKING
}

@export_category("Beginning State")
@export var state: State = State.IDLE

@onready var animated_sprite = $AnimatedSprite3D
@onready var alert_timer = $AlertTimer
@onready var attack_interval_timer = $AttackIntervalTimer

# Steering Behavior Components
@onready var agent := await GSAICharacterBody3DAgent.new(self)
@onready var target := GSAIAgentLocation.new()
@onready var accel := GSAITargetAcceleration.new()
@onready var blend := GSAIBlend.new(agent)
@onready var face := GSAIFace.new(agent, target, true)
@onready var arrive := GSAIArrive.new(agent, target)

@export_category("Movement Variables")
@export var movement_speed: float = 3.0
@export var acceleration: float = 5.0
@export var deceleration_distance: float = 2.0
@export var arrival_distance: float = 0.5

@export_category("Attack Variables")
@export var damage: float = 50.0
@export var bullet = load('res://scenes/guns/melee_bullet.tscn')

var aware_of_player = false
var can_attack = true
var target_node: Node3D = null

func _ready():
	# Setup steering behaviors
	blend.add(arrive, 1)
	blend.add(face, 1)
	
	# Configure steering variables
	agent.linear_speed_max = movement_speed
	agent.linear_acceleration_max = acceleration
	agent.linear_drag_percentage = 0.05
	arrive.arrival_tolerance = arrival_distance
	arrive.deceleration_radius = deceleration_distance
	face.alignment_tolerance = deg_to_rad(5) 
	face.deceleration_radius = deg_to_rad(45)

func _physics_process(delta):
	match state:
		State.CHASING:
			if target_node:
				# Update target for movement
				target.position = target_node.global_position
				target.position.y = global_position.y
				
				#Move based on steering addon
				blend.calculate_steering(accel)
				agent._apply_steering(accel, delta)
				velocity = agent.linear_velocity
				move_and_slide()
			
		State.ATTACKING:
			# Decelleration when reaching player
			if velocity.length() > 0.2:
				velocity = velocity.move_toward(Vector3.ZERO, movement_speed * delta)
				move_and_slide()
			else:
				velocity = Vector3.ZERO
				if can_attack and bullet:
					can_attack = false
					attack_interval_timer.start()

			# Keeps CharacterBody node rotating in 3D space correctly
			if target_node:
				target.position = target_node.global_position
				face.calculate_steering(accel)
				agent._apply_steering(accel, delta)
				
		_:
				velocity = Vector3.ZERO

func instance_bullet():
	var projectile = bullet.instantiate()
	projectile.is_enemy_bullet = true
	projectile.damage = damage
	projectile.global_position = global_position
	projectile.global_transform.basis = global_transform.basis
	projectile.get_node("HitboxComponent").set_collision_layer_value(1, false)
	projectile.get_node("HitboxComponent").set_collision_layer_value(2, true)
	add_child(projectile)

func _process(delta):
	match state:
		State.IDLE:
			animated_sprite.play('walkLeft')
		State.ALERTED:
			animated_sprite.play('alerted')
		State.CHASING:
			animated_sprite.play('walkForward')
		State.ATTACKING:
			animated_sprite.play("attack")

func _on_detection_area_body_entered(body):
	if body.name == 'Player':
		target_node = body
		if not aware_of_player:
			aware_of_player = true
			state = State.ALERTED
			alert_timer.start()
		else:
			state = State.CHASING

func _on_detection_area_body_exited(body):
	if body.name == 'Player':
		target_node = null
		state = State.IDLE

func _on_attack_area_body_entered(body):
	if body.name == 'Player':
		state = State.ATTACKING


func _on_attack_area_body_exited(body):
	if body.name == 'Player':
		state = State.CHASING


func _on_alert_timer_timeout():
	if state == State.ALERTED:
		state = State.CHASING


func _on_attack_interval_timer_timeout():
	if state == State.ATTACKING:
		instance_bullet()
	
	can_attack = true
