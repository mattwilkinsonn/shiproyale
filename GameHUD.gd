extends Control

const Game = preload("res://Game.gd")

@export var SHRINKING_TEXT = "SHRINKING"
@export var WAITING_TEXT = "WAITING"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_healthbar(new_health: int):
	$HealthBar.value = new_health

func set_storm_label(storm_state: Game.StormState):
	if storm_state == Game.StormState.SHRINKING:
		$StormLabel.text = SHRINKING_TEXT
		return
	
	$StormLabel.text = WAITING_TEXT
