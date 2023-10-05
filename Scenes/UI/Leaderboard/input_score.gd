extends Control

signal score_submit(player_input)

var player_name

func _on_submit_pressed():
	player_name = $MarginContainer/PanelContainer/Panel/VBoxContainer/LineEdit.text
	if player_name != '':
		emit_signal("score_submit", player_name)
