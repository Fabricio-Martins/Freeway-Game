extends CharacterBody2D

@export var move_speed : float = 75
@export var starting_direction : Vector2 = Vector2(0, 1)

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var starting_position = global_position

@onready var screen_size
@onready var pause = false
@onready var colliding = false 
@onready var colliding_time = 0

signal scored
signal damage

func _ready():
	update_animation_parameters(starting_direction)
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	if pause:
		return
	if colliding:
		colliding_time -= delta
		position.y += move_speed * delta
		if colliding_time <= 0:
			colliding_time = 0
			colliding = false

		return
		
	var input_direction = Vector2(
		Input.get_action_strength("wasd_right") - Input.get_action_strength("wasd_left"),
		Input.get_action_strength("wasd_down") - Input.get_action_strength("wasd_up")
	)
	input_direction = input_direction.normalized()	
	
	update_animation_parameters(input_direction)

	velocity = input_direction * move_speed
	
	position.x = clamp(position.x, 10, screen_size.x - 7.5)
	position.y = clamp(position.y, 10, screen_size.y - 7.5)
	
	move_and_slide()	
	pick_new_state()
	
func update_animation_parameters(move_input : Vector2):
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)
		animation_tree.set("parameters/Knockback/blend_position", move_input)

func pick_new_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

func _on_collision_detector_area_entered(area):
	if area.name == "HazardArea":
		emit_signal("damage")
		knockback()
	elif area.name == "VictoryLine":
		emit_signal("scored")

func paused():
	pause = true
	process_mode = PROCESS_MODE_DISABLED
	global_position = starting_position

func knockback():
	colliding = true
	state_machine.travel("Knockback")
	colliding_time = 0.5
