extends RigidBody2D

const PlayArea = preload("res://PlayArea.gd")
const ProjectileScene = preload("res://Projectile.tscn")
const Coin = preload("res://Coin.gd")
const Port = preload("res://Port.gd")

signal fire(pos, impulse)
signal health_changed(health)
signal currency_changed(currency)
signal entered_port()
signal left_port()

@export var MOVEMENT_FORCE = 50
@export var ROTATIONAL_TORQUE = 900.0
@export var MAX_SPEED = 100
@export var PROJECTILE_IMPULSE = 400

var is_local_player = false
@onready var camera: Camera2D = get_node("/root/Game/Camera2D")

var current_movement_input = Vector2.ZERO
var current_rotation_input = 0
@export var health: int:
	get:
		return health
	set(new_health):
		health_changed.emit(new_health)
		health = new_health
		
		if multiplayer.is_server() and health == 0:
			destroy_player.rpc()
			

@export var currency: int = 0:
	get:
		return currency
	set(new_currency):
		currency_changed.emit(new_currency)
		currency = new_currency

enum ShipState {
	NORMAL,
	IN_PORT
}

@export var ship_state: ShipState = ShipState.NORMAL:
	get:
		return ship_state
	set(new_ship_state):
		if ship_state == ShipState.NORMAL and new_ship_state == ShipState.IN_PORT:
			entered_port.emit()
		
		print("ship states:")
		print(ship_state)
		print(new_ship_state)
		if ship_state == ShipState.IN_PORT and new_ship_state == ShipState.NORMAL:
			left_port.emit()
		
		ship_state = new_ship_state

@rpc("authority", "call_local", "reliable")
func destroy_player():
	if is_local_player:
		health_changed.emit(0)
	queue_free()

func _ready():
	health = 100

func is_in_play_area() -> bool:
	return $PlayerArea.overlaps_area(Globals.play_area)

func check_storm_tick():
	if is_in_play_area():
		return

	if $StormTickTimer.is_stopped():
		$StormTickTimer.start(2)

func _on_storm_tick_timer_timeout():
	if is_in_play_area():
		return
		
	health -= 10
	$StormTickTimer.start(0.5)
	

	

func _process(delta: float):
	if multiplayer.is_server():
		check_storm_tick()
		return
	
	if not is_local_player:
		return
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	var rotation_direction = Input.get_axis("Rotate Counterclockwise", "Rotate Clockwise")
	receive_player_movement_input.rpc_id(1, input_direction, rotation_direction)
	camera.position = position
	
	
@rpc("any_peer", "call_remote", "unreliable_ordered")
func receive_player_movement_input(input_direction: Vector2, rotation_direction: float):
	current_movement_input = input_direction
	current_rotation_input = rotation_direction
	
func _physics_process(delta: float):
	if multiplayer.is_server():
		set_movement(current_movement_input)
		calculate_rotation(current_rotation_input)

func set_movement(input_direction: Vector2):
	apply_central_force(input_direction * MOVEMENT_FORCE)
	
func calculate_rotation( rotation_direction: float):
	apply_torque(rotation_direction * ROTATIONAL_TORQUE)

#func get_angle_change(delta: float, rotation_direction: float):
	#return ROTATIONAL_VELOCITY_RADIANS * delta * rotation_direction
	



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
	var pos = global_position + (fire_vector * 50)
	var impulse = fire_vector * PROJECTILE_IMPULSE
	fire.emit(pos, impulse)

func collect_coin(coin: Coin):
	currency += coin.VALUE
	coin.destroy_coin.rpc()

@rpc("authority", "call_local", "reliable")
func enter_port():
	ship_state = ShipState.IN_PORT

@rpc("authority", "call_local", "reliable")
func leave_port():
	ship_state = ShipState.NORMAL

func _on_player_area_area_entered(area: Area2D):
	if not multiplayer.is_server():
		return
	
	if area is Coin:
		collect_coin(area)
		return
		
	if area is Port:
		enter_port.rpc()
		return


func _on_player_area_area_exited(area: Area2D):
	if area is Port:
		leave_port.rpc()
		return
