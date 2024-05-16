extends Node2D
 
var peer = WebSocketMultiplayerPeer.new()
@export var player_scene: PackedScene
@export var bot_scene: PackedScene

signal game_error(what)


func _ready():
	RivetHelper.start_server.connect(start_server)
	RivetHelper.setup_multiplayer()

func start_server():
	peer.create_server(8080)
	multiplayer.set_multiplayer_peer(peer)
	var response = await Rivet.matchmaker.lobbies.ready({})
	if response.result == OK:
		RivetHelper.rivet_print("Lobby ready")
	else:
		RivetHelper.rivet_print("Lobby ready failed")
		OS.crash("Lobby ready failed")
	# add bot
	_add_bot()
	multiplayer.peer_connected.connect(_add_player)
 
func _on_host_pressed():
	var err = peer.create_server(8080)
	print(err)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_bot()
	_add_player()
	
 
func _add_player(id = 1):
	print('adding player')
	var player = player_scene.instantiate()
	player.host = id
	player.name = str(id)
	print(player.host)
	call_deferred("add_child", player, true)

func _add_bot(id = 1):
	print('adding bot')
	var bot = bot_scene.instantiate()
	call_deferred("add_child", bot, true)


func join_game(new_player_name):
	print("Joining game as %s" % new_player_name)
	var player_name = new_player_name

	var response = await Rivet.matchmaker.lobbies.find({
		"game_modes": ["default"]
	})

	if response.result == OK:
		RivetHelper.set_player_token(response.body.player.token)

		var port = response.body.ports.default
		print("Connecting to ", port.host)
		print(response.body)
		var prepend = 'ws://'
		if port.is_tls:
			prepend = 'wss://'
		var error = peer.create_client(prepend + port.host)
		RivetHelper._assert(!error, "Could not start server")
		multiplayer.set_multiplayer_peer(peer)
	else:
		print("Lobby find failed: ", response)
		game_error.emit(response.body)
 
func _on_join_pressed():
	join_game('guest')
