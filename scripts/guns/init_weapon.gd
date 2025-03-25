extends Node3D

@export var gun: Weapon

@onready var weapon_mesh : MeshInstance3D 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func load_weapon() -> void:
	#weapon_mesh.mesh = weapon_type.mesh
	print("Loaded and armed with ",gun.weapon_name)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_weapon_name(): return gun.weapon_name
func get_damage(): return gun.damage
func get_reserve_ammo(): return gun.reserve_ammo
func get_mag(): return gun.mag
func get_mag_size(): return gun.magazine_size
