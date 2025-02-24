extends Node3D

@onready var anim_tree = self.find_child('AnimationTree')
@onready var anim_state = anim_tree.get("parameters/playback")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Boss has loaded")
	anim_tree.active = true
	
	anim_state.travel("mutant_breathing_idle")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_area_3d_area_entered(area: Area3D) -> void:
	print('Boss spotted Player')
	anim_state.travel('mutant_roaring')


func _on_area_3d_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	print('Boss spotted Player from shape')
	anim_state.travel('mutant_roaring')


func _on_area_3d_body_entered(body: Node3D) -> void:
	print('Boss spotted Player')
	anim_state.travel('mutant_roaring')
