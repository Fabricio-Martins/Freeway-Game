extends Control

var timer = null
var flag = 0

func _ready():
	$MarginContainer/VBoxContainerOne/Singleplayer.grab_focus()

func _on_singleplayer_pressed():
	get_tree().change_scene_to_file("res://Scenes/Scenario/singleplayer.tscn")
	get_tree().paused = false

func _on_multiplayer_pressed():
	get_tree().change_scene_to_file("res://Scenes/Scenario/multiplayer.tscn")
	get_tree().paused = false

func _on_exit_pressed():
	get_tree().quit()
