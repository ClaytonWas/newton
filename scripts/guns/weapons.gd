class_name Weapons extends Resource

@export var name : StringName
@export_category("Weapon Orientation")
@export var position : Vector3
@export var rotation: Vector3

@export_category("Visual Settings")
@export var mesh: Mesh
@export var shadow: bool

@export_category("Weapon Stats")
@export var damage: float
@export var magazine_size: int
@export var total_ammo: int
@export var reload_time: float
@export var spread: float			#Bloom multiplier
@export var isMelee: bool = false
