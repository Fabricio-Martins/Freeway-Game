extends Control

signal go_back

var player_name
var Scoreline = preload("res://Scenes/UI/Leaderboard/scoreline.tscn")

func _ready():
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	print("Scores: " + str(sw_result.scores))
	var scores = sw_result.scores
	
	var idx=1
	for score in scores:
		var line=Scoreline.instantiate()
		line.get_node("PlayerPosition").text = str(idx) + "."
		line.get_node('PlayerName').text = score.player_name
		line.get_node('PlayerScore').text = str(int(score.score))
		$MarginContainer/PanelContainer/VBoxContainer/PanelContainer/Scorebox.add_child(line)
		idx+=1

func _on_return_pressed():
	emit_signal("go_back")
