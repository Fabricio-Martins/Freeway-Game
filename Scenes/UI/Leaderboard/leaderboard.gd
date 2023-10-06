extends Control

signal go_back

var player_name
var Scoreline = preload("res://Scenes/UI/Leaderboard/scoreline.tscn")

func sort_by_score(a, b):
	if int(a[1]) > int(b[1]):
		return true
	return false
	
func _load_local_scoreboard():
	for score in $MarginContainer/PanelContainer/VBoxContainer/PanelContainer/Scorebox.get_children():
		score.queue_free()
	var score_list = _read_scores_file("res://local_leaderboard.txt")
	var score_data
	var scores = []
	for score in score_list:
		if not score:
			continue
		score_data = score.split('+')
		scores.append(score_data)
	
	scores.sort_custom(sort_by_score)
	
	var idx=1
	for score in scores:
		if idx > 5:
			break
		var line=Scoreline.instantiate()
		line.get_node("PlayerPosition").text = str(idx) + "."
		line.get_node('PlayerName').text = score[0]
		line.get_node('PlayerScore').text = score[1]
		$MarginContainer/PanelContainer/VBoxContainer/PanelContainer/Scorebox.add_child(line)
		idx+=1

func _ready():
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	print("Scores: " + str(sw_result.scores))
	# var scores = sw_result.scores
	_load_local_scoreboard()

func _on_return_pressed():
	emit_signal("go_back")


func _read_scores_file(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var score_list = file.get_as_text()
	file.close()
	return score_list.rsplit('\n')
	
func write_scores_file(filename, scores):
	var file = FileAccess.open(filename, FileAccess.WRITE)
	for score in scores:
		file.store_string(score) # Cada linha seria tipo: "Nome+Score;"
	file.close()




func _on_singleplayer_mode_show_leaderboard():
	_load_local_scoreboard()
