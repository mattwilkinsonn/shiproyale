extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var args = OS.get_cmdline_user_args()
	for arg in args:
		if arg == "server":
			create_server()
			break
		if arg == "client":
			wait(1)
			join_server()
			break
	pass # Replace with function body.

func create_server():
	Lobby.create_server()
	$LobbyMenu.set_start_game_enabled(true)

func join_server():
	
	#Lobby.player_info.name = $CenterContainer/VBoxContainer/Username.text
	Lobby.player_info.name = str(randi())
	Lobby.join_server($LobbyMenu.get_server_ip())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _on_lobby_menu_create_server():
	create_server()

func _on_lobby_menu_join_server():
	join_server()
