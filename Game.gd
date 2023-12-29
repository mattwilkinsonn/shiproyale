extends Node2D

const PlayerScene = preload("res://Player.tscn")

func _ready():
	# Preconfigure game.
	Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.

var player_characters = {}


# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	for player_id in Lobby.players:
		create_character.rpc(player_id)
		
@rpc("authority", "call_local", "reliable", 2)
func create_character(id: int):
	var character = PlayerScene.instantiate()
	player_characters[id] = character
	character.global_position = $SpawnPoint.global_position
	if multiplayer.get_unique_id() == id:
		character.is_local_player = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
