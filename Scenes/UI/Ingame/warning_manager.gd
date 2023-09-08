extends CanvasLayer

func _ready():
	$MarginContainer/AnimationPlayer.play("FlashText")

func change_message(message):
	$MarginContainer/Message.text = message
