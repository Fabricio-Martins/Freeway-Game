extends Node2D

const new_car = preload("res://MiniGames/Freeway/Scenes/Characters/Enemies/Car.tscn")

var slow_road = [198, 158, 138, 98, 79]
var fast_road = [178, 118, 58]

var lives = 5
var player_score = 0

func _on_timer_fast_road_timeout():
	var fast_car = new_car.instantiate()
	add_child(fast_car)
	fast_car.position.y = fast_road[randi() % fast_road.size()]
	if fast_car.position.y > 140:
		fast_car.position.x = -10
		fast_car.linear_velocity = Vector2(randf_range(300, 310), 0)
	else:
		fast_car.position.x = 440
		fast_car.linear_velocity = Vector2(randf_range(-300, -310), 0)


func _on_timer_slow_road_timeout():
	var slow_car = new_car.instantiate()
	add_child(slow_car)
	slow_car.position.y = slow_road[randi() % slow_road.size()]
	if slow_car.position.y > 140:
		slow_car.position.x = -10
		slow_car.linear_velocity = Vector2(randf_range(150, 160), 0)
	else:
		slow_car.position.x = 440
		slow_car.linear_velocity = Vector2(randf_range(-150, -160), 0)


func _on_chicken_player_damage():
	lives -= 1
	var text = "Lives Left: %d"
	$CanvasLayer/Health.text = text % [lives]
	if lives == 0:
		$TimerFastRoad.stop()
		$TimerSlowRoad.stop()
		$CanvasLayer/GameOver.text = "GAME OVER!"
		$ChickenPlayer.paused()
		lives = 5


func _on_chicken_player_scored():
	player_score += 1
	$CanvasLayer/Scoreboard.text = str(player_score)
	if player_score >= 3:
		$CanvasLayer/GameOver.text = "YOU WON!"
		$ChickenPlayer.paused()
		$TimerFastRoad.stop()
		$TimerSlowRoad.stop()
