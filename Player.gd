extends CharacterBody2D

const ProjectileScene = preload("res://Projectile.tscn")

signal fire(pos, impulse)

@export var MOVEMENT_SPEED = 100
@export var ROTATIONAL_VELOCITY = 90.0

var ROTATIONAL_VELOCITY_RADIANS = deg_to_rad(ROTATIONAL_VELOCITY)
var is_local_player = false

var current_movement_input = Vector2.ZERO
var current_rotation_input = 0

func _process(delta: float):
	if not is_local_player:
		return
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	var rotation_direction = Input.get_axis("Rotate Counterclockwise", "Rotate Clockwise")
	receive_player_movement_input.rpc_id(1, input_direction, rotation_direction)
	
	
@rpc("any_peer", "call_remote", "unreliable_ordered")
func receive_player_movement_input(input_direction: Vector2, rotation_direction: float):
	current_movement_input = input_direction
	current_rotation_input = rotation_direction
	
func _physics_process(delta: float):
	set_movement(current_movement_input)
	calculate_rotation(delta, current_rotation_input)

	move_and_slide()

func set_movement(input_direction: Vector2):
	velocity = input_direction * MOVEMENT_SPEED
	
func calculate_rotation(delta: float, rotation_direction: float):
	var current_angle = rotation
	
	var angle_change = get_angle_change(delta, rotation_direction)
	
	var new_angle = current_angle + angle_change
	rotation = lerp_angle(current_angle, new_angle, 1)

func get_angle_change(delta: float, rotation_direction: float):
	return ROTATIONAL_VELOCITY_RADIANS * delta * rotation_direction
	



func _input(event: InputEvent):
	if not is_local_player:
		return
	if event.is_action_pressed("Fire"):
		fire_action.rpc_id(1)
		
@rpc("any_peer", "call_remote", "unreliable")
func fire_action():
	# get current rotation
	var left_fire_direction = global_rotation - (PI / 2)
	var right_fire_direction = global_rotation + (PI / 2)
	
	fire_projectile(left_fire_direction)
	fire_projectile(right_fire_direction)

func fire_projectile(fire_direction: float):
	var projectile = ProjectileScene.instantiate()
	
	var fire_vector = Vector2.UP.rotated(fire_direction)
	
 	# TODO: get edge of ship's collison box and position there
	var pos = global_position + (fire_vector * 20)
	var impulse = fire_vector * 150
	fire.emit(pos, impulse)

	
	
	
	
