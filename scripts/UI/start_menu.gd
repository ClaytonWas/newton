extends Control

@export_category('Scenes')
@export var main_scene_path: String = "res://scenes/UI/shop.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_panel($ButtonPanel)
	GameScript.start_game() #Resets game loop variables

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


func _on_music_button_toggled(toggled_on: bool) -> void:
	#Toggles music on/off
	GameScript.settings_toggle('music')


func _on_volume_silder_value_changed(value: float) -> void:
	# Sets global game volume
	GameScript.set_volume(value)
