extends Area2D

const Game = preload("res://Game.gd")

@export var SHRINK_SPEED = 10.0

var is_shrinking = false



# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.play_area = self
	pass # Replace with function body.


func get_storm_state() -> Game.StormState:
	return get_node("/root/Game").storm_state
	
@rpc("authority", "call_remote", "unreliable")
func sync_storm_radius(radius: float):
	if $CollisionShape2D.shape.radius == radius:
		return
	
	$CollisionShape2D.shape.radius = radius
	queue_redraw()	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not multiplayer.is_server():
		return
	
	if get_storm_state() == Game.StormState.SHRINKING:
		$CollisionShape2D.shape.radius -= SHRINK_SPEED * delta
		
		
	sync_storm_radius.rpc($CollisionShape2D.shape.radius)
	
func _draw():
	draw_arc(Vector2.ZERO, $CollisionShape2D.shape.radius, 0, TAU, 100, Color.RED, 5, true)
