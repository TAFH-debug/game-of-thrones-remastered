extends Node

const PORT = 4433
const MAX_PLAYERS = 4

var peer := ENetMultiplayerPeer.new()

func _ready():
	host_game()
	
func host_game() -> void:
	peer.create_server(PORT, MAX_PLAYERS)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start server.")
		return
	multiplayer.multiplayer_peer = peer

func join_game(ip: String) -> void:
	peer.create_client(ip, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to connect.")
		return
	multiplayer.multiplayer_peer = peer
