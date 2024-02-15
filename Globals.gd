extends Node

const Player = preload("res://Player.gd")

@export var play_area: Area2D
@export var local_player: Player
@export var local_player_dead: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
