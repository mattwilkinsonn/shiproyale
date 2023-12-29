extends Control

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
	Lobby.player_info.name = $CenterContainer/VBoxContainer/Username.text
	Lobby.join_server($CenterContainer/VBoxContainer/ServerIp.text)


func _on_create_server_pressed():
	Lobby.create_server()
	$CenterContainer/VBoxContainer/StartGame.disabled = false


func _on_player_connected(peer_id: int, player_info: Dictionary):
	var player_label = Label.new()
	player_label.text = str(peer_id) + ": " + player_info.name
	$CenterContainer/VBoxContainer/PlayerList.add_child(player_label)
	labels[peer_id] = player_label


func _on_player_disconnected(peer_id: int):
	labels[peer_id].queue_free()
	


func _on_start_game_pressed():
	Lobby.load_game.rpc("res://Game.tscn")
