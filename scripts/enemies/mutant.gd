extends CharacterBody3D

@onready var anim_tree = self.find_child('AnimationTree')
@onready var anim_state = anim_tree.get("parameters/playback")

@export_category("Boss Stats")
@export var run_speed: float	#TODO change to composition from enemy
@export var health: float = 500

@export var light_dmg: float = 25
@export var heavy_dmg: float = 55
var is_attacking: bool = false
var is_running: bool = false
var movement_vector : Vector3 = Vector3.ZERO


func _ready() -> void:
	print("Boss has loaded")
	anim_tree.active = true
	anim_state.travel("mutant_idle")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	
	if is_running:
		move_and_collide(movement_vector * delta)
	else:
		movement_vector = Vector3.ZERO

func _on_vision_area_body_entered(body: Node3D) -> void:
	movement_vector = (body.global_transform.origin - global_transform.origin).normalized() * run_speed
	#When vision area is entered
	if not is_attacking:
		print('Boss spotted Player')
		anim_state.travel('mutant_run')
		is_running = true

func _on_attack_area_body_entered(body: Node3D) -> void:	
	#When attack radius is entered
	is_running = false
	print('Boss attacking')
	anim_state.travel('mutant_punch')
