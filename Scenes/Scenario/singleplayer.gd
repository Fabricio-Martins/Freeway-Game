extends Node2D

const new_car = preload("res://Scenes/Characters/Enemies/Car.tscn")

@onready var slow_road = [164, 133, 104, 88, 58, 43]
@onready var fast_road = [148, 118, 73, 28]
@onready var starting_position = $ChickenPlayer.global_position
@onready var lives = 5
@onready var player_score = 0
@onready var event_duration = 10
@onready var warning_duration = 5

func _ready():
	pass
	#$UI/WarningManager.visible = false
	
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
	var text = "Lives Left: %d"
	$UI/Health.text = text % [lives]
	$ChickenPlayer.global_position = starting_position
	if lives == 0:
		$TimerFastRoad.stop()
		$TimerSlowRoad.stop()
		$UI/MarginContainer/GameOver.text = "GAME OVER!"
		$ChickenPlayer.paused()
		lives = 5


func _on_chicken_player_scored():
	player_score += 1
	$UI/Scoreboard.text = str(player_score)
	$ChickenPlayer.global_position = starting_position
	if player_score >= 3:
		$UI/MarginContainer/GameOver.text = "YOU WON!"
		$ChickenPlayer.paused()
		$TimerFastRoad.stop()
		$TimerSlowRoad.stop()

func _on_timer_event_timeout():
	pass

func _on_timer_warning_timeout():
	$UI/WarningManager.change_message("ALSO TRY ESPULETA!")
	$UI/WarningManager.visible = true
	await get_tree().create_timer(warning_duration).timeout
	$UI/WarningManager.visible = false
