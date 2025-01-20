extends Control

@export var bg_clr : Color
@export var border_clr : Color = Color.WHITE_SMOKE

@export var border_width: float = 3
@export var outer_radius: float = 256                  #TODO: Wheel size proportional to screen?
@export var inner_radius: float 

@export var options = []
var inventoryOpen : bool = false
var menuOpen: bool = false

func _draw():
	var points = []
	var d : float		#middle distance between lines
	var bg : Color = Color.DARK_SLATE_GRAY
	bg.a = 0.7
	draw_rect(Rect2(get_viewport_rect().size * -1,get_viewport_rect().size * 2), bg, true)
	draw_circle(Vector2.ZERO, outer_radius, bg_clr)
	draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 128, border_clr, border_width, true)

	if len(options) >= 3:			# Draw divider lines based on inventory size 
		for i in range(len(options) - 1):
			var rads = TAU * i/((len(options) - 1))
			points.append(Vector2.from_angle(rads))			
			
			draw_line(points[-1]*inner_radius,points[-1]*outer_radius,Color.BLACK,border_width+4,true)	# Draws divider + border lines
			draw_line(points[-1]*inner_radius,points[-1]*outer_radius,border_clr,border_width,true)
			draw_arc(Vector2.ZERO, outer_radius, rads,  2*rads, 128, Color.BLACK)
							
			print(points[-1]*inner_radius,points[-1]*outer_radius)	
			#Put image on each inv slot
			if points.size() > 1:
				#Calculate middle distance
				#middle point d = sqrt((x2-x1)^2 + (y2-y1)^2) / 2
				d = ( ((points[-1][0] * outer_radius ) - (points[-2][0] * inner_radius))**2) +  \
					(((points[-1][1] * outer_radius) - (points[-2][1] * inner_radius))**2)
				d = sqrt(d) / 2
				
				
				draw_circle(points[-1]*d, 40, Color.PINK)
				print("drawn cirlce ",i)
				
		draw_circle(points[0]*d, 40, Color.PINK)
		draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 128, border_clr, border_width, true)
	
func _ready():
	pass

func _physics_process(delta: float):
	pass

func _process(delta):
	if Input.is_action_pressed("inventory_toggle"):
		inventoryOpen = true
	else:
		inventoryOpen = false

	if(!menuOpen):
		if inventoryOpen:
			self.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			self.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		menuOpen = !menuOpen
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			inventoryOpen = false
			self.visible = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
