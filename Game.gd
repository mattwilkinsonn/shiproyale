extends Node

const Player = preload("res://Player.gd")
const PlayerScene = preload("res://Player.tscn")
const ProjectileScene = preload("res://Projectile.tscn")

enum StormState {
	SHRINKING,
	WAITING
}

@export var STORM_TIME = 10

@export var storm_state: StormState = StormState.WAITING:
	get:
		return storm_state
	set(new_storm_state):
		$CanvasLayer/GameHUD.set_storm_label(new_storm_state)
		storm_state = new_storm_state

func _ready():
	# Preconfigure game.
	$ProjectileSpawner.set_spawn_function(projectile_spawn)
	Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.

var player_characters = {}

@export var total_players: int
@export var alive_players: int


# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	for player_id in Lobby.players:
		create_player.rpc(player_id)
	total_players = Lobby.players.size()
	alive_players = Lobby.players.size()
	update_players_remaining.rpc(alive_players, total_players)
	
	storm_state = StormState.WAITING
	$StormTimer.start(STORM_TIME)
		
@rpc("authority", "call_local", "reliable")
func create_player(id: int):
	var player = PlayerScene.instantiate()
	player_characters[id] = player
	player.global_position = $Map.get_spawn_point()
	if multiplayer.get_unique_id() == id:
		setup_local_player(player)
	player.fire.connect(_on_player_fire)
	player.client_id = id
	if multiplayer.is_server():
		player.death.connect(_on_player_death)
	add_child(player)
		
func _on_player_death(id: int):
	alive_players -= 1
	update_players_remaining.rpc(alive_players, total_players)

@rpc("authority", "call_local", "reliable")
func update_players_remaining(new_alive_players: int, new_total_players: int):
	alive_players = new_alive_players
	total_players = new_total_players
	$CanvasLayer/GameHUD.update_players_remaining(alive_players, total_players)
	
	if alive_players == 1 and Globals.local_player_dead == false:
		$CanvasLayer/GameHUD.show_victory_menu()
	

func setup_local_player(player: Player):
	player.is_local_player = true
	player.health_changed.connect(_on_local_player_health_changed)
	player.currency_changed.connect(_on_local_player_currency_changed)
	player.entered_port.connect(_on_local_player_entered_port)
	player.left_port.connect(_on_local_player_left_port)
	Globals.local_player = player
	
func _on_local_player_entered_port():
	$CanvasLayer/GameHUD.show_port_menu()

func _on_local_player_left_port():
	$CanvasLayer/GameHUD.hide_port_menu()

func _on_local_player_currency_changed(new_currency: int):
	$CanvasLayer/GameHUD.update_currency(new_currency)

func _on_local_player_health_changed(new_health: int):
	$CanvasLayer/GameHUD.update_healthbar(new_health)
	
	if new_health <= 0:
		$CanvasLayer/GameHUD.show_loss_menu()

func _on_player_fire(pos, impulse, damage):
	$ProjectileSpawner.spawn({"pos": pos, "impulse": impulse, "damage": damage})

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func projectile_spawn(data):
	var projectile = ProjectileScene.instantiate()
	projectile.DAMAGE = data.damage
	projectile.position = data.pos
	projectile.apply_central_impulse(data.impulse)
	return projectile
	
func flip_storm_state():
	if storm_state == StormState.WAITING:
		storm_state = StormState.SHRINKING
		return
	
	storm_state = StormState.WAITING
	
func _on_storm_timer_timeout():
	if multiplayer.is_server():
		flip_storm_state()
		$StormTimer.start(STORM_TIME)

