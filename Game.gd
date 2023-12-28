extends Node2D

func _ready():
	# Preconfigure game.
	
	Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.


# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
