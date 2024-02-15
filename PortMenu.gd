extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_damage_button_pressed():
	Globals.local_player.damage_upgrade.rpc_id(1)

func _on_speed_button_pressed():
	Globals.local_player.speed_upgrade.rpc_id(1)

func _on_fire_rate_button_pressed():
	Globals.local_player.fire_rate_upgrade.rpc_id(1)
