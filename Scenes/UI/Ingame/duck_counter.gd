extends Control

signal timer_ended

func _on_singleplayer_mode_duck_timer():
	$AnimationPlayer.play("default")

func _on_animation_player_animation_finished(anim_name):
	emit_signal("timer_ended")


func _on_multiplayer_mode_duck_timer():
	$AnimationPlayer.play("default")
