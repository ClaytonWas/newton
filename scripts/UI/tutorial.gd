extends CanvasLayer

var panel_node = preload('res://scenes/UI/ui_tip_panel.tscn')

# Title : Message key-value pairs for tutorial tips
var tutorial = {
	'Welcome to Gloom' : 'This is a Demo World where you can test out the controls.\n\n
		Get comfortable with your abilities & prepare for battle.',
	"Got the time?" : 'Keep an eye on your watch. When you run out of time the game is over.',
	'End Game' : ' Defeat The Boss before you meet your maker.'
	}
	
var tip_list : Array = []

func _ready() -> void:
	if not GameScript.skip_tutorial and tutorial.size() > 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Engine.time_scale = 0.0	# Pause Game time when shown
		show_tip(tutorial.keys()[0], tutorial[tutorial.keys()[0]])

func _process(delta: float) -> void:
	if GameScript.skip_tutorial:
		queue_free()
	
	if not GameScript.skip_tutorial and tutorial.size() > 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#If First tip was clicked
		if tip_list.size() > 0:
			if tip_list[0].was_clicked:
				#Remove from list
				tutorial.erase(tutorial.keys().front())	
				tip_list.pop_front()
				#Delete node
				%Tutorial.get_child(0).queue_free()	
				#Show next
				if not GameScript.skip_tutorial and tutorial.size() > 0:
					show_tip(tutorial.keys()[0], tutorial[tutorial.keys()[0]])
			
					
				else:	# Delete 
					GameScript.skip_tutorial = true
					%right_hand.can_shoot = true
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					queue_free()
		
func show_tip(title: String, message: String):
	# UI_Tip_Panel Element variables
	var panel_node = preload('res://scenes/UI/ui_tip_panel.tscn')
	var panel = panel_node.instantiate()
	var label_1 = panel.find_child('BGPanel').find_child('Title')
	var desc = panel.find_child('BGPanel').find_child('BodyPanel').get_child(0)
	
	label_1.text = title.to_upper()
	desc.text = message

	tip_list.append(panel)
	self.add_child(panel)

	#Accept UI input
	var plyr = get_tree().current_scene.find_child("Player")
	%right_hand.can_shoot = false

func toggle_pause() -> void:
	#Toggles pause game menu & functionality
	if Engine.time_scale > 0.0:
		Engine.time_scale = 0.0
		%right_hand.can_shoot = false
	else:
		Engine.time_scale = 1.0
		%right_hand.can_shoot = true
