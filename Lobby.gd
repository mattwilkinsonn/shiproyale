extends Node
# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id: int, player_info: Dictionary)
signal player_disconnected(peer_id: int)
signal server_disconnected

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Name"}

var players_loaded = 0

var game_started = false

func _ready():
	# multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_server(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func create_server():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server() and not game_started:
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game.start_game()
			game_started = true


@rpc("any_peer", "reliable")
func _register_player_on_server(new_player_info: Dictionary):
	var new_player_id = multiplayer.get_remote_sender_id()
	_update_players_on_connect.rpc_id(new_player_id, players)
	_new_player_connected.rpc(new_player_id, new_player_info)

@rpc("authority", "call_local", "reliable")
func _new_player_connected(id: int, new_player_info: Dictionary):
	players[id] = new_player_info
	player_connected.emit(id, new_player_info)

@rpc("authority", "call_local", "reliable")
func _player_disconnected(id: int):
	players.erase(id)
	player_disconnected.emit(id)

@rpc("authority", "call_remote", "reliable")
func _update_players_on_connect(current_players: Dictionary):
	players = current_players
	for player_id in current_players:
		player_connected.emit(player_id, players[player_id])

func _on_player_disconnected(id: int):
	if not multiplayer.is_server():
		return
	
	_player_disconnected.rpc(id)

func _on_connected_ok():
	_register_player_on_server.rpc_id(1, player_info)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
