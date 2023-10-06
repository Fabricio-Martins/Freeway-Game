extends Control

var timer = null
var flag = 0

var _is_full_screen: bool = true

func _ready():
	$MarginContainer/VBoxContainerOne/Singleplayer.grab_focus()

func _toggle_fullscreen() -> void:
	_is_full_screen = not _is_full_screen
	
	if _is_full_screen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
func _on_fullscreen_pressed():
	_toggle_fullscreen()
	
func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		_toggle_fullscreen();
		
func _on_singleplayer_pressed():
	get_tree().change_scene_to_file("res://Scenes/Scenario/singleplayer.tscn")
	get_tree().paused = false

func _on_multiplayer_pressed():
	get_tree().change_scene_to_file("res://Scenes/Scenario/multiplayer.tscn")
	get_tree().paused = false

func _on_exit_pressed():
	get_tree().quit()

func _on_leaderboard_pressed():
	$Leaderboard.visible = true


func _on_leaderboard_go_back():
	$Leaderboard.visible = false
