extends CanvasLayer

#UI Elements
var background: ColorRect
var title: RichTextLabel
var redo_button: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visibility_changed.connect(self.toggle_time_scale)
	background = self.find_child('ColorRect')
	title = self.find_child('Panel').find_child('RichTextLabel')
	redo_button = self.find_child('Panel').get_child(1).find_child('Button')
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func toggle_time_scale():
	if Engine.time_scale:
		Engine.time_scale = 0.0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else: 
		Engine.time_scale = 1.0
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_player_death_screen():
	visible = true


func _on_button_pressed():
	GameScript.on_restart()


func _on_quit_button_button_down() -> void:
	print('Pressed quit\n\n\n')
	get_tree().quit()


func _on_restart_button_down() -> void:
	Engine.time_scale = 1.0
	GameScript.on_restart()


func make_win_screen():
	self.visible = true
	background.color = Color(0, 100, 0, 0.65)
	title.text = 'GAME OVER\nyou win'
	title.add_theme_color_override("font_outline_color", Color.DARK_GREEN)  
	redo_button.add_theme_color_override('font_color', Color.GREEN)
	redo_button.add_theme_color_override('font_hover_color', Color.GREEN)
