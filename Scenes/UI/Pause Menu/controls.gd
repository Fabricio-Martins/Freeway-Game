extends Control

signal previous

func _on_return_pressed():
	emit_signal("previous")
