extends Node

var lobby: Lobby
var game: GameServer

func _ready():
	lobby = Lobby.new()
	game = GameServer.new()
	add_child(lobby)
	add_child(game)
