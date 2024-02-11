extends Control

signal create_server
signal join_server

var labels = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	Lobby.player_connected.connect(_on_player_connected)
	Lobby.player_disconnected.connect(_on_player_disconnected)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_join_server_pressed():
	join_server.emit()


func set_start_game_enabled(enabled: bool):
	$CenterContainer/VBoxContainer/StartGame.disabled = !enabled
	

func get_username() -> String:
	return $CenterContainer/VBoxContainer/Username.text

func get_server_ip() -> String:
	return $CenterContainer/VBoxContainer/ServerIp.text

func _on_create_server_pressed():
	create_server.emit()
	


func _on_player_connected(peer_id: int, player_info: Dictionary):
	var player_label = Label.new()
	player_label.text = str(peer_id) + ": " + player_info.name
	$CenterContainer/VBoxContainer/PlayerList.add_child(player_label)
	labels[peer_id] = player_label


func _on_player_disconnected(peer_id: int):
	labels[peer_id].queue_free()
	


func _on_start_game_pressed():
	Lobby.load_game.rpc("res://Game.tscn")
