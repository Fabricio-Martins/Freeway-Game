extends Node2D

const new_car = preload("res://Scenes/Characters/Enemies/Car.tscn")

@onready var slow_road = [164, 133, 104, 88, 58, 43]
@onready var fast_road = [148, 118, 73, 28]
@onready var starting_position_one = $ChickenPlayerOne.global_position
@onready var starting_position_two = $ChickenPlayerTwo.global_position
@onready var score_player_one = 0
@onready var score_player_two = 0
@onready var event_duration = 5
@onready var warning_duration = 5
@onready var events = ["slow", "stuck", "invert"]
var current_event

signal slow_event
signal stuck_event
signal invert_event
signal fog_event
signal duck_timer

var _is_full_screen: bool = true

func _ready():
	$UI/EndScreen.visible = false
	
func _toggle_fullscreen() -> void:
	_is_full_screen = not _is_full_screen
	
	if _is_full_screen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
func _on_fullscreen_pressed():
	_toggle_fullscreen();

func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		_toggle_fullscreen();
	
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
	pass

func _play_scored_jingle(score, player):
	var pitch_list = [0, 2, 4, 5, 7, 1, 2, 3, 4]
	
	if player == 1:
		$ScoredSFX.position.x = -400
	else:
		$ScoredSFX.position.x = 400
	
	if score <= 5:
		$ScoredSFX.set_pitch_scale(1 + ((pitch_list[score - 1]/7.0)/2))
		$ScoredSFX.play()
	elif score > 5 and score < 10:
		$ScoredSFX.set_pitch_scale(1.5 + ((pitch_list[score - 1])/5.0)/2)
		$ScoredSFX.play()
	elif score % 10 == 0:
		$Scored10SFX.play()

func _on_chicken_player_one_scored():
	$ChickenPlayerOne.global_position = starting_position_one
	score_player_one += 1
	_play_scored_jingle(score_player_one, 1)
	
	if score_player_one <= 10:
		$UI/ScoreboardOne.text = str(score_player_one)
	if score_player_one >= 10:
		$UI/EndScreen.visible = true
		$UI/EndScreen/VBoxContainer/GameOver.text = "Player One Won!"
		$ChickenPlayerOne.paused()
		$ChickenPlayerTwo.paused()
		$TimerFastRoad.stop()
		$TimerSlowRoad.stop()
		$GameTheme.stop()
		$GameOverSFX.play()
		await $GameOverSFX.finished
		$GameOverTheme.play()


func _on_chicken_player_two_scored():
	$ChickenPlayerTwo.global_position = starting_position_two
	score_player_two += 1
	_play_scored_jingle(score_player_two, 2)
	
	if score_player_two <= 10:
		$UI/ScoreboardTwo.text = str(score_player_two)
	if score_player_two >= 10:
		$UI/EndScreen.visible = true
		$UI/EndScreen/VBoxContainer/GameOver.text = "Player Two Won!"
		$ChickenPlayerOne.paused()
		$ChickenPlayerTwo.paused()
		$TimerFastRoad.stop()
		$TimerSlowRoad.stop()
		$GameTheme.stop()
		$GameOverSFX.play()
		await $GameOverSFX.finished
		$GameOverTheme.play()


func _on_timer_event_timeout():
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


func _on_duck_counter_timer_ended():
	$UI/duckCounter.visible = false
