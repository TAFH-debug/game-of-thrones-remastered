extends Node
class_name PeerConnector

const PORT = 4433
const MAX_PLAYERS = 4

var peer := ENetMultiplayerPeer.new()
	
func host_game() -> bool:
	peer.create_server(PORT, MAX_PLAYERS)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start server.")
		return false
	multiplayer.multiplayer_peer = peer
	return true

func join_game(ip: String) -> bool:
	peer.create_client(ip, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to connect.")
		return false
	multiplayer.multiplayer_peer = peer
	return true
	
