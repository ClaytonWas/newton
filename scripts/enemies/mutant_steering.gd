extends CharacterBody3D

enum State {
	IDLE,
	ALERTED,
	CHASING,
	ATTACKING,
	STUNNED
}

@export var target_node: CharacterBody3D

@export_category("Beginning State")
@export var state: State = State.IDLE

@export_category("Movement Variables")
@export var movement_speed: float = 3.0

@export_category("Attack Variables")
@export var damage: float = 75.0
@export var bullet = load('res://scenes/guns/melee_bullet.tscn')

@export_group("Sound Variables")
@export var run_sound = preload('res://sounds/Enemy/MutantBoss/boss_running_sound.wav')
@export var roar_sound = preload('res://sounds/Enemy/MutantBoss/mutant_roar_sound.wav')
@export var hurt_sound: AudioStreamWAV
@export var idle_sound: AudioStreamWAV
@export var hit_sound: AudioStreamWAV
@export var death_sound = preload('res://sounds/Enemy/MutantBoss/mutant_die_sound.mp3')

# Steering Addons
@onready var agent := await GSAICharacterBody3DAgent.new(self)
@onready var target := GSAIAgentLocation.new()
@onready var accel := GSAITargetAcceleration.new()
@onready var blend := GSAIBlend.new(agent)
@onready var face := GSAIFace.new(agent, target, true)
@onready var arrive := GSAIArrive.new(agent, target)
# State Control Elements
@onready var animation = $AnimationPlayer
@onready var alert_timer = $AlertTimer
@onready var attack_interval_timer = $AttackIntervalTimer
@onready var stun_timer = $StunTimer
@onready var navigation_agent = $NavigationAgent3D
@onready var audio = $AudioBoss

var is_attacking: bool = false
var aware_of_player: bool = false
var can_attack: bool = true
var stunned: bool = false
var attack_counter: int	# Counter to alternate swipe and punch
var hit_counter: int	# Tracks how many times boss shot before stun

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
	print('Mutant is setup for ',target_node.name)

func _ready():
	animation.play('mutant_breathing_idle')
	attack_counter = 0
	hit_counter = 0

	%HealthBar.max_value = %HealthComponent.max_health
	%HealthBar.value = %HealthComponent.max_health
	
func _physics_process(delta: float) -> void:
	match state:
		State.CHASING:
			if target_node and not stunned:
				target.position = target_node.transform.origin
				target.position.y = transform.origin.y
				blend.calculate_steering(accel)
				agent._apply_steering(accel, delta)
				navigation_agent.set_target_position(target_node.position)
				var next_path_pos = navigation_agent.get_next_path_position()
				var direction = (next_path_pos - global_position).normalized()
				#Move based on steering addon
				velocity = direction * movement_speed
				move_and_slide()
				
				if not audio.is_playing(): # Play run sound
					audio.stream = run_sound
					audio.play()
				if not (animation.current_animation == 'mutant_swiping' or animation.current_animation == 'mutant_roar' or animation.current_animation == 'mutant_punch'):
					animation.play('mutant_run_(1)')
				
		State.ATTACKING:
			# Decelleration when reaching player
			velocity = Vector3.ZERO
			if can_attack: #and bullet:
				can_attack = false
				attack_counter += 1
				
				if not animation.current_animation == "mutant_stun":
					if attack_counter % 2 == 0:
						animation.play("mutant_swiping")
						attack_interval_timer.wait_time = animation.get_animation("mutant_swiping").length
					else:
						animation.play("mutant_punch")
						attack_interval_timer.wait_time = animation.get_animation("mutant_punch").length
					attack_interval_timer.start()
			
		State.STUNNED:
			velocity = velocity.move_toward(Vector3.ZERO, movement_speed * delta)
			move_and_slide()
			animation.play("mutant_stun")
			if not audio.is_playing():
				audio.stream = hurt_sound
				
		State.ALERTED:
			animation.play('mutant_roaring')
		
		State.IDLE:
			animation.play('mutant_breathing_idle')
			velocity = Vector3.ZERO
			# Play sound	
		_:
			velocity = Vector3.ZERO

func instance_bullet():
	var projectile = bullet.instantiate()
	projectile.is_enemy_bullet = true
	projectile.damage = damage
	projectile.global_position = global_position
	projectile.scale = Vector3(2,2,2)
	projectile.global_transform.basis = global_transform.basis
	add_child(projectile)

func _process(delta):
	match state:
		State.STUNNED:
			if not stunned and target_node:
				state = State.CHASING

func _on_punch_finished():
	animation.play("mutant_punch")
	print('punching')
	#animation.animation_finished.disconnect(_on_punch_finished)

func _on_vision_area_body_entered(body):
	if body.name == 'Player':
		target_node = body
		if not aware_of_player:
			aware_of_player = true
			state = State.ALERTED
			# Play sound
			audio.stream = roar_sound
			audio.play()
			alert_timer.start()
		else:
			state = State.CHASING

func _on_vision_area_body_exited(body):
	if body.name == 'Player':
		#target_node = null
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
		pass
	can_attack = true

func _on_health_component_damage_taken():
	# When Boss is shot
	%HealthBar.value = %HealthComponent.health
	hit_counter += 1
	if not stunned and hit_counter % 4 == 0:
		state = State.STUNNED
		stunned = true
		stun_timer.start()
		print('stunned')

func _on_stun_timer_timeout():
	stunned = false

func _on_tree_exiting() -> void:
	# When Boss dies
	GameScript.game_won = true
	audio.stream = death_sound
	audio.play()
