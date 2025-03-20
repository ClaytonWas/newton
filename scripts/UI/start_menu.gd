extends Control

@export_category('Scenes')
@export var main_scene_path: String = "res://scenes/levels/outdoors.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_panel($ButtonPanel)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_button_button_down() -> void:
	get_tree().quit()


func _on_play_button_button_down() -> void:
	get_tree().change_scene_to_file(main_scene_path)


func _on_back_button_button_down() -> void:
	#Reload current scene
	var scene_path = 'res://scenes/levels/start_menu.tscn'
	get_tree().change_scene_to_file(scene_path)


func _on_how_to_play_button_button_down() -> void:
	change_panel($IntructionsPanel)

func change_panel(panel):
	#Changes visibility of button panels
	$ButtonPanel.visible = false
	$IntructionsPanel.visible = false
	$SettingsPanel.visible = false
	
	panel.visible = true


func _on_setting_button_button_down() -> void:
	change_panel($SettingsPanel)
