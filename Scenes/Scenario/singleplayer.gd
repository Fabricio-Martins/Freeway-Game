extends Node2D

const new_car = preload("res://Scenes/Characters/Enemies/Car.tscn")
var Scoreline = preload("res://Scenes/UI/Leaderboard/scoreline.tscn")

@onready var slow_road = [133, 104, 88, 58, 43]
@onready var fast_road = [148, 118, 73, 28]
@onready var starting_position = $ChickenPlayer.global_position
@onready var lives = 5
@onready var player_score = 0
@onready var event_duration = 10
@onready var warning_duration = 5
@onready var events = ["slow", "stuck", "invert"]
var current_event

signal slow_event
signal stuck_event
signal invert_event
signal fog_event
signal show_leaderboard
signal game_over
signal player_cant_move
signal player_can_move
signal duck_timer

var tempo = 0
var _cooldown_timer: float = 0.5
var _is_full_screen: bool = true
var _is_invulnerable: bool = false
var _game_over: bool = false
var _is_last_life: bool = false
var _score_already_submitted: bool = false

@onready var heart_size = 16
@onready var max_hearts = lives

func life_changed():
	$UI/Lives.set_size(Vector2(max_hearts * heart_size, 0))
	if lives <= 0:
		$UI/Lives.visible = false
	
func _ready():
	$UI/EndScreen.visible = false
	$UI/TimerEvento.visible = false
	life_changed()

func _toggle_fullscreen() -> void:
	_is_full_screen = not _is_full_screen
	
	if _is_full_screen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
func _on_fullscreen_pressed():
	_toggle_fullscreen()
	
func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		_toggle_fullscreen();
	$UI/TimerEvento.text = "EVENT DURATION: " + str($EventDuration.time_left)
	
func _on_timer_fast_road_timeout():
	var fast_car = new_car.instantiate()
	add_child(fast_car)
	fast_car.position.y = fast_road[randi() % fast_road.size()]
	if fast_car.position.y > 90:
		fast_car.position.x = -8
		fast_car.linear_velocity = Vector2(randf_range(200, 210), 0)
	else:
		fast_car.set_scale(Vector2(-1, -1))
		fast_car.position.x = 328
		fast_car.linear_velocity = Vector2(randf_range(-200, -210), 0)


func _on_timer_slow_road_timeout():
	var slow_car = new_car.instantiate()
	add_child(slow_car)
	slow_car.position.y = slow_road[randi() % slow_road.size()]
	if slow_car.position.y > 90:
		slow_car.position.x = -8
		slow_car.linear_velocity = Vector2(randf_range(100, 110), 0)
	else:
		slow_car.set_scale(Vector2(-1, -1))
		slow_car.position.x = 328
		slow_car.linear_velocity = Vector2(randf_range(-100, -110), 0)


func _on_chicken_player_damage():
	lives -= 1
	max_hearts = lives
	life_changed()
	var text = "Lives Left: %d"
	if lives >= 0:
		$UI/Health.text = text % [lives]
	$ChickenPlayer.global_position = starting_position
	
	emit_signal("player_cant_move")
	await get_tree().create_timer(_cooldown_timer).timeout
	emit_signal("player_can_move")
	
	if _is_last_life == false:
		_is_invulnerable = true
		await get_tree().create_timer(0.5).timeout
		_is_invulnerable = false
	
	if lives == 1: _is_last_life = true
	
	if lives <= 0:
		$ChickenPlayer.paused()
		_game_over = true
		emit_signal("game_over")
		$TimerFastRoad.stop()
		$TimerSlowRoad.stop()
		$UI/EndScreen.visible = true
		$UI/EndScreen/VBoxContainer/GameOver.text = "GAME OVER!"
		lives = 5
		$SingleplayerTheme.stop()
		$GameOverSFX.play()
		await $GameOverSFX.finished
		$GameOverTheme.play()

func _on_chicken_player_scored():
	player_score += 1
	$UI/Scoreboard.text = str(player_score)
	
	var pitch_list = [0, 2, 4, 5, 7, 1, 2, 3, 4]
	
	if player_score <= 5:
		$ScoredSFX.set_pitch_scale(1 + ((pitch_list[player_score - 1]/7.0)/2))
		$ScoredSFX.play()
	elif player_score > 5 and player_score < 10:
		$ScoredSFX.set_pitch_scale(1.5 + ((pitch_list[player_score - 1])/5.0)/2)
		$ScoredSFX.play()
	elif player_score % 10 == 0:
		$Scored10SFX.play()
	else:
		$ScoredSFX.set_pitch_scale(2)
		$ScoredSFX.play()
	
	emit_signal("player_cant_move")
	await get_tree().create_timer(_cooldown_timer).timeout
	emit_signal("player_can_move")
	
	$ChickenPlayer.global_position = starting_position
	
	
	# Condição de Vitória
	#if player_score >= 3:
	#	$UI/MarginContainer/GameOver.text = "YOU WON!"
	#	$ChickenPlayer.paused()
	#	$TimerFastRoad.stop()
	#	$TimerSlowRoad.stop()

func _on_timer_event_timeout():
	if !_game_over:
		current_event = events[randi() % events.size()]
		match(current_event):
			"slow":
				await change_warning("SLOW EVENT!")
				emit_signal("slow_event")
			"stuck":
				await change_warning("CLASSIC MODE EVENT!")
				emit_signal("stuck_event")
			"invert":
				await change_warning("CONFUSION EVENT!")
				emit_signal("invert_event")
			"fog":
				pass
				#emit_signal("fog_event")
	emit_signal("duck_timer")
	$UI/duckCounter.visible = true

func change_warning(event_name):
	$UI/WarningManager.change_message(event_name)
	$UI/WarningManager.visible = true
	await get_tree().create_timer(warning_duration).timeout
	$UI/WarningManager.visible = false


func _on_play_again_pressed():
	get_tree().reload_current_scene()


func _on_back_to_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/Menu/menu.tscn")


func _on_score_button_pressed():
	$UI/EndScreen.visible = false
	$UI/InputScore.visible = true
	_score_already_submitted = false
	$UI/EndScreen/VBoxContainer/ScoreButton.visible = false

func _on_input_score_score_submit(player_name):
	# player_name = player_name.to_lower()
	$UI/InputScore.visible = false
	$UI/Leaderboard.visible = true
	SilentWolf.Scores.save_score(player_name, player_score)
	print_debug("Score persisted successfully: " + str(player_name))
	
	#var current_scores = str(player_name, "+", player_score, "\n")
	#print(current_scores)
	#var scores = _read_scores_file("res://local_leaderboard.txt")
	#_write_scores_file("res://local_leaderboard.txt", current_scores)
	
	emit_signal("show_leaderboard")

func _load_local_scoreboard():
	var score_list = _read_scores_file("res://local_leaderboard.txt")
	var score_data
	var scores = []
	for score in score_list:
		if not score:
			continue
		score_data = score.split('+')
		scores.append({"Name": score_data[0], "Score": score_data[1]})
	
	var idx=1
	for score in scores:
		var line = Scoreline.instantiate()
		line.get_node("PlayerPosition").text = str(idx) + "."
		line.get_node('PlayerName').text = score["Name"]
		line.get_node('PlayerScore').text = score["Score"]
		$UI/Leaderboard/MarginContainer/PanelContainer/VBoxContainer/PanelContainer/Scorebox.add_child(line)
		idx+=1

func _read_scores_file(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var score_list = file.get_as_text()
	file.close()
	return score_list.rsplit(';')
	
func _write_scores_file(filename, scores):
	var file = FileAccess.open(filename, FileAccess.READ_WRITE)
	file.seek_end()
	for score in scores:
		file.store_string(score) # Cada linha seria tipo: "Nome+Score\n"
	file.close()


func _on_leaderboard_go_back():
	$UI/Leaderboard.visible = false
	$UI/EndScreen.visible = true
	

func _on_input_score_exit_pressed():
	$UI/InputScore.visible = false
	$UI/EndScreen/VBoxContainer/ScoreButton.visible = true
	$UI/EndScreen.visible = true


func _on_duck_counter_timer_ended():
	$UI/duckCounter.visible = false
