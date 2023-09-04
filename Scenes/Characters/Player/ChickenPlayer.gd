extends CharacterBody2D

@export var move_speed : float = 125
@export var starting_direction : Vector2 = Vector2(0, 1)

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var starting_position = global_position

var screen_size
var pause = false
signal scored
signal damage

func _ready():
	update_animation_parameters(starting_direction)
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	var input_direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
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

func pick_new_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

func _on_collision_detector_area_entered(area):
	if area.name == "HazardArea":
		emit_signal("damage")
		global_position = starting_position
	elif area.name == "VictoryLine":
		emit_signal("scored")
		global_position = starting_position

func paused():
	pause = true
	process_mode = PROCESS_MODE_DISABLED
	global_position = starting_position
	
