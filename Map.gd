extends Node2D


func get_spawn_point() -> Vector2:
	for spawn_point in $SpawnPoints.get_children():
		if spawn_point.HAS_SPAWNED == false:
			spawn_point.HAS_SPAWNED = true
			return spawn_point.position
			
	return Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
