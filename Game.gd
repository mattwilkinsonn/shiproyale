extends Node2D

const Player = preload("res://Player.gd")
const PlayerScene = preload("res://Player.tscn")
const ProjectileScene = preload("res://Projectile.tscn")

func _ready():
	# Preconfigure game.
	$ProjectileSpawner.set_spawn_function(projectile_spawn)
	Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.

var player_characters = {}


# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	for player_id in Lobby.players:
		create_player.rpc(player_id)
		
@rpc("authority", "call_local", "reliable", 2)
func create_player(id: int):
	var player = PlayerScene.instantiate()
	player_characters[id] = player
	player.global_position = $SpawnPoint.global_position
	if multiplayer.get_unique_id() == id:
		setup_local_player(player)
	player.fire.connect(_on_player_fire)
	add_child(player)

func setup_local_player(player: Player):
	player.is_local_player = true
	player.health_changed.connect(_on_local_player_health_changed)

func _on_local_player_health_changed(new_health: int):
	$GameHUD.update_healthbar(new_health)

func _on_player_fire(pos, impulse):
	$ProjectileSpawner.spawn({"pos": pos, "impulse": impulse})

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func projectile_spawn(data):
	var projectile = ProjectileScene.instantiate()
	projectile.position = data.pos
	projectile.apply_central_impulse(data.impulse)
	return projectile
	
