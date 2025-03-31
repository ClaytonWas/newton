extends Control

@export_category("Crosshair Settings")
@export var ch_length: float = 100
@export var ch_radius: float = 20
@export var ch_color: Color = Color.HOT_PINK
@export var ch_opacity: float = 1
@export var ch_width: float = 5
@export var center_dot: bool = true
@export var dot_size: float = 1

var center = get_viewport_rect().size / 2
var thickness = ch_width / 2
var isVisible: bool = true

func _draw():
	ch_color.a = ch_opacity 
	
	#Crosshair bar coords
	var top_ch = Rect2(-thickness,-ch_radius - thickness, thickness, -(ch_radius + ch_length))
	var bottom_ch = Rect2(-thickness,ch_radius + thickness, thickness, ch_radius + ch_length)
	var left_ch = Rect2( -(ch_radius+thickness),-thickness, -(ch_length + ch_radius), thickness)
	var right_ch = Rect2(ch_radius + thickness ,-thickness, ch_length + ch_radius, thickness)
	
	#Draw crosshair
	if center_dot: draw_circle(Vector2(-0.666666667,-0.666666667), dot_size,ch_color,true)
	draw_rect(top_ch, ch_color, true)
	draw_rect(left_ch, ch_color, true)
	draw_rect(right_ch, ch_color, true)
	draw_rect(bottom_ch, ch_color, true)

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Disable HUD when menu or inventory opens
func _process(delta):
	queue_redraw()
	
	if Input.is_action_pressed("inventory_toggle"):
		isVisible = false
	else:
		isVisible = true

	if isVisible:
		self.visible = true
	
	else:
		self.visible = false
