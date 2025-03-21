extends CharacterBody3D

signal death_screen

@export_category("Camera Controls")
@export var mouse_sensitivity := 0.002
const headbob_shake := 0.025
const headbob_frequency := 0.5
@export var headbob_time := 0.0

@export_category("Player Stats")
@export var health: float = 100	#Total health
@export var heal_rate: float = 3	#Time interval of healing
@export var heal_interval: float = 20	#Amount healed per interval
var is_dead: bool = false

@export_category("Movement Variables")
@export var walk_speed := 30.0
@export var sprint_speed := 100.0
@export var jump_strength := 14.0
@export var air_speed_cap := 0.85
@export var air_speed_acceleration := 800.0
@export var air_move_speed := 500.0
@export var ground_speed_acceleration := 7.5
@export var ground_speed_deceleration := 7.5
@export var ground_friction := 5

var target_velocity = Vector3.ZERO
var current_velocity = Vector3.ZERO

var desired_direction := Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		%PauseMenu.visible = false
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		toggle_pause()		#Pause game on esc key
		
		
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * mouse_sensitivity)
			%Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-70), deg_to_rad(70))

func _headbob_effect(delta) -> void:
	headbob_time += delta * self.velocity.length()
	%Camera3D.transform.origin = Vector3(
		cos(headbob_time * headbob_frequency * 0.5) * headbob_shake,
		sin(headbob_time * headbob_frequency * 0.5) * headbob_shake,
		0
	)

func get_move_speed() -> float:
	if Input.is_action_pressed("sprint"):
		return sprint_speed 
	else:
		return walk_speed	

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back").normalized()
	desired_direction = self.global_transform.basis * Vector3(direction.x, 0.0, direction.y)
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			self.velocity.y = jump_strength
		else:
			_floor_physics(delta)
	else:
		_air_physics(delta)
	
	move_and_slide()	

func _floor_physics(delta) -> void:
	var current_speed_in_desired_direction = self.velocity.dot(desired_direction)
	var add_speed_till_cap = get_move_speed() - current_speed_in_desired_direction
	if add_speed_till_cap > 0:
		var accel_speed = ground_speed_acceleration * delta * get_move_speed()
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * desired_direction
	
	# Apply friction
	var grip = max(self.velocity.length(), ground_speed_deceleration)
	var deceleration_from_grip = grip * ground_friction * delta
	var new_speed = max(self.velocity.length() - deceleration_from_grip, 0.0)
	if self.velocity.length() > 0:
		new_speed /= self.velocity.length()
	self.velocity *= new_speed
	
	_headbob_effect(delta)
	
func _air_physics(delta) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	# How fast is the player already moving into the direction they want to go in:
	var current_speed_in_desired_direction = self.velocity.dot(desired_direction)
	# This code allows to to gain momentumn in air like the source engine:
	var capped_speed = min((air_move_speed * desired_direction).length(), air_speed_cap)
	var add_speed_till_cap = capped_speed - current_speed_in_desired_direction
	if add_speed_till_cap > 0:
		var current_acceleration = air_speed_acceleration * air_move_speed * delta
		current_acceleration = min(current_acceleration, add_speed_till_cap)
		self.velocity += current_acceleration * desired_direction

func take_damage(dmg:int):
		health -= dmg
		
		if health <= 0:
			death_state()

func _on_timer_timeout():
	death_state()

func death_state():
	is_dead = true
	emit_signal("death_screen")
	$BodyCollisionShape.queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_script(null)


func _on_death_zone_body_entered(body: Node3D) -> void:
	emit_signal("death_screen")

func toggle_pause() -> void:
	#Toggles pause game menu & functionality
	if Engine.time_scale > 0.0:
		Engine.time_scale = 0.0
	else:
		Engine.time_scale = 1.0
	if %PauseMenu.visible:
		%PauseMenu.visible = false
	else:
		%PauseMenu.visible = true

func _on_resume_button_down() -> void:
	toggle_pause()
