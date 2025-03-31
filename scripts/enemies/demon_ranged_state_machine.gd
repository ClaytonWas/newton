extends CharacterBody3D

enum State {
	IDLE,
	ALERTED,
	CHASING,
	ATTACKING,
	STUNNED
}

@export_category("Beginning State")
@export var state: State = State.IDLE

@onready var animated_sprite = $AnimatedSprite3D
@onready var alert_timer = $AlertTimer
@onready var attack_interval_timer = $AttackIntervalTimer
@onready var stun_timer = $StunTimer
@onready var navigation_agent = $NavigationAgent3D

@export_category("Movement Variables")
@export var movement_speed: float = 3.0

@export_category("Attack Variables")
@export var damage: float = 50.0
@export var bullet = load('res://scenes/guns/melee_bullet.tscn')

var aware_of_player: bool = false
var can_attack: bool = true
var stunned: bool = false
var target_node: Node3D = null

func _ready():
	pass

func _physics_process(delta):
	match state:
		State.CHASING:
			if target_node:
				navigation_agent.set_target_position(target_node.position)
				var next_path_pos = navigation_agent.get_next_path_position()
				var direction = (next_path_pos - global_position).normalized()
				#Move based on steering addon
				velocity = direction * movement_speed
				move_and_slide()
			
		State.ATTACKING:
			# Stop moving when attacking
			velocity = Vector3.ZERO
			move_and_slide()
			if can_attack and bullet:
				can_attack = false
				attack_interval_timer.start()
			
		State.STUNNED:
			velocity = velocity.move_toward(Vector3.ZERO, movement_speed * delta)
			move_and_slide()
				
		_:
			velocity = Vector3.ZERO

func instance_bullet():
	if not target_node:  # Safety check
		return
	
	var projectile = bullet.instantiate()
	projectile.is_enemy_bullet = true
	projectile.damage = damage
	
	# Spawn at demon's position with Y offset
	var spawn_position = global_position
	spawn_position.y += 0.5  # Adjust this value as needed
	
	# Set position and rotation in global space
	projectile.global_position = spawn_position
	
	# Calculate direction to player
	var direction = (target_node.global_position - spawn_position).normalized()
	
	# Make bullet face the player
	projectile.look_at(target_node.position + direction, Vector3.UP)
	
	# Add to scene - IMPORTANT: Add to the scene root instead of self
	get_tree().current_scene.add_child(projectile)
func _process(delta):
	match state:
		State.IDLE:
			animated_sprite.play('idle')
			animated_sprite.set_billboard_mode(0)
		State.ALERTED:
			animated_sprite.play('alerted')
		State.CHASING:
			animated_sprite.play('walkForward')
			animated_sprite.set_billboard_mode(1)
		State.ATTACKING:
			animated_sprite.play("attack")
		State.STUNNED:
			animated_sprite.play('stunned')
			animated_sprite.modulate = Color(1, 0.25, 0.25)
			if not stunned and target_node:
				animated_sprite.modulate = Color(1, 1, 1)
				state = State.ATTACKING  # Return to attacking after stun

func _on_detection_area_body_entered(body):
	if body.name == 'Player':
		target_node = body
		if not aware_of_player:
			aware_of_player = true
			state = State.ALERTED
			alert_timer.start()
		else:
			state = State.ATTACKING  # Immediately attack when player enters detection

func _on_detection_area_body_exited(body):
	if body.name == 'Player':
		pass

func _on_attack_area_body_entered(body):
	if body.name == 'Player' and aware_of_player:
		state = State.ATTACKING

func _on_attack_area_body_exited(body):
	if body.name == 'Player':
		state = State.CHASING
		
func _on_alert_timer_timeout():
	if state == State.ALERTED:
		state = State.ATTACKING  # Start attacking after alert period

func _on_attack_interval_timer_timeout():
	if state == State.ATTACKING and target_node:
		instance_bullet()
		can_attack = true

func _on_health_component_damage_taken():
	state = State.STUNNED
	stunned = true
	stun_timer.start()

func _on_stun_timer_timeout():
	stunned = false
	if target_node:
		state = State.ATTACKING  # Return to attacking after stun
	else:
		state = State.IDLE
