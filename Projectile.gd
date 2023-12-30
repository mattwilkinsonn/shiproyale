extends RigidBody2D

const Player = preload("res://Player.gd")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_gameplay_area_body_entered(body: Node2D):
	if body is Player:
		body.health -= 10
	queue_free()
	pass # Replace with function body.
