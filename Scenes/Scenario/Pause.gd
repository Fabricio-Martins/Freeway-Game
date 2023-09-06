extends Control

var pause = false

func _ready():
	pass
	visible = false
	#$ControlsHud.visible = false
	
func _input(event):
	pass
	if event.is_action_pressed("ui_cancel"):
		pause =  !pause
		get_tree().paused = pause
		visible = pause
		print("passou")

func _on_ResumeButton_pressed():
	print("passou1")
	get_tree().paused = false
	visible = false
	print("passou2")

func _on_ExitButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/Menu/menu.tscn")

func _on_ControlsButton_pressed():
	$".".visible = false
	#$ControlsHud.visible = true

func _on_ReturnButton_pressed():
	$".".visible = true
	#$ControlsHud.visible = false

func _on_menu_pressed():
	pause = !pause
	get_tree().paused = pause
	visible = pause
