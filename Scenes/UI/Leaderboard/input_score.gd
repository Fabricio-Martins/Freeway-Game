extends Control

signal score_submit(player_input)

var player_name

signal exit_pressed

func _on_submit_pressed():
	player_name = $MarginContainer/PanelContainer/Panel/VBoxContainer/VBoxContainer2/LineEdit.text
	if player_name != '':
		emit_signal("score_submit", player_name)


func _on_exit_pressed():
	emit_signal("exit_pressed")
