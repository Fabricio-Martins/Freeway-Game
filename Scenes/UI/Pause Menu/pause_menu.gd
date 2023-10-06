extends Control

var pause = false
var _game_over: bool = false

func _ready():
	visible = false
	$Controls.visible = false
	
func _input(event):
	if event.is_action_pressed("ui_cancel") and not _game_over:
		pause =  !pause
		get_tree().paused = pause
		visible = pause

func _on_ResumeButton_pressed():
	pause = !pause
	get_tree().paused = pause
	visible = pause

func _on_ExitButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/Menu/menu.tscn")

func _on_ControlsButton_pressed():
	#visible = false
	$Controls.visible = true

func _on_menu_pressed():
	if _game_over:
		return
	pause = !pause
	get_tree().paused = pause
	visible = pause

func _on_controls_previous():
	$Controls.visible = false
	visible = true


func _on_singleplayer_mode_game_over():
	_game_over = true
