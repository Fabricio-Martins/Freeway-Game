extends RigidBody2D

func _ready():
	var car_color = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.animation = car_color[randi() % car_color.size()]

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
