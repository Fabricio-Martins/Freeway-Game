extends Control

signal go_back

var player_name
var Scoreline = preload("res://Scenes/UI/Leaderboard/scoreline.tscn")

func _ready():
	pass
	#_load_online_scoreboard()
	#_load_local_scoreboard()

func _load_online_scoreboard():
	await get_tree().create_timer(1).timeout
	
	for score in $MarginContainer/PanelContainer/VBoxContainer/PanelContainer/Scorebox.get_children():
		score.queue_free()
		
	var _sw_result: Dictionary = await SilentWolf.Scores.get_scores(5, "tournament").sw_get_scores_complete
	var scores = _sw_result.scores
		
	var idx=1
	for score in scores:
		if idx > 5:
			break
		var line=Scoreline.instantiate()
		line.get_node("PlayerPosition").text = str(idx) + "."
		line.get_node('PlayerName').text =score.player_name
		line.get_node('PlayerScore').text = str(score.score)
		$MarginContainer/PanelContainer/VBoxContainer/PanelContainer/Scorebox.add_child(line)
		idx+=1

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
	_load_online_scoreboard()
	#_load_local_scoreboard()


func _on_menu_show_leaderboard():
	_load_online_scoreboard()
	#_load_local_scoreboard()
