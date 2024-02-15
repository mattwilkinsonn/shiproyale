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

func update_currency(new_currency: int):
	$CurrencyLabel.text = "Currency: " + str(new_currency)
	
func update_players_remaining(alive_players: int, max_players: int):
	$PlayersRemainingLabel.text = "Players Remaining: " + str(alive_players) + "/" + str(max_players)

func update_healthbar(new_health: int):
	$HealthBar.value = new_health

func set_storm_label(storm_state: Game.StormState):
	if storm_state == Game.StormState.SHRINKING:
		$StormLabel.text = "SHRINKING"
		return
	
	$StormLabel.text = "WAITING"

func show_port_menu():
	$PortMenu.visible = true

func hide_port_menu():
	$PortMenu.visible = false
	
func show_loss_menu():
	$LossMenu.visible = true
	
func show_victory_menu():
	$VictoryMenu.visible = true

