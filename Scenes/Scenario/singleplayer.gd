extends Node2D

const new_car = preload("res://Scenes/Characters/Enemies/Car.tscn")

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

var tempo = 0
var _is_full_screen: bool = true
var _is_invulnerable: bool = false
var _game_over: bool = false
var _is_last_life: bool = false

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
	
func _process(delta):
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
	
	if _is_last_life == false:
		_is_invulnerable = true
		await get_tree().create_timer(0.5).timeout
		_is_invulnerable = false
	
	if lives == 1: _is_last_life = true
	
	if lives <= 0:
		$ChickenPlayer.paused()
		_game_over = true
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
	$ChickenPlayer.global_position = starting_position
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


func _on_input_score_score_submit(player_name):
	$UI/InputScore.visible = false
	$UI/Leaderboard.visible = true
	SilentWolf.Scores.save_score(player_name, player_score)
	print_debug("Score persisted successfully: " + str(player_name))


func _on_leaderboard_go_back():
	$UI/Leaderboard.visible = false
	$UI/EndScreen.visible = true
