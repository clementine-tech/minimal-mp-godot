extends Node2D
 
var peer = WebSocketMultiplayerPeer.new()
@export var player_scene: PackedScene
@export var bot_scene: PackedScene
 
 
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
 
 
func _on_join_pressed():
	var socket_url: String
	if OS.has_feature('web'):
		# we are in a browser now check if in discord 
		var location: String = JavaScriptBridge.eval("window.location.host;")
		if location.contains("discord"):
			socket_url = "wss://" + location + "/ws"
		else:
			socket_url = "wss://shepherd-eastern-novelty-catalogue.trycloudflare.com"
	else:
		socket_url = "ws://" + "localhost" + ":" + str(8080)
	#var socket_url = "wss://ja-differ-papers-ver.trycloudflare.com"
	var err = peer.create_client(socket_url)
	print(err)
	multiplayer.multiplayer_peer = peer
