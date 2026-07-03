extends Node

var lobby: Lobby
var game: GameServer

func _ready():
	_create_children()
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.connection_failed.connect(_on_server_disconnected)

func _create_children():
	lobby = Lobby.new()
	lobby.name = "Lobby"
	game = GameServer.new()
	game.name = "GameServer"
	add_child(lobby)
	add_child(game)

## Drop the connection and rebuild lobby/game state for a fresh session.
func reset():
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	lobby.free()
	game.free()
	_create_children()

func _on_server_disconnected():
	reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
