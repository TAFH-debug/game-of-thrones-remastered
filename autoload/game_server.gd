extends Node
class_name GameServer

enum Stage { PLANNING, WESTEROS }
var stage: Stage = Stage.PLANNING
var players: Array[GamePlayerData] = []
var influence_tracks: Array = []

func start_game(players: Array[PlayerData]):
	pass
	
@rpc("authority")
func setup_game(players: Array[Dictionary]):
	for i in players:
		var gp_data = GamePlayerData.new()
		gp_data.id = i["id"]
		gp_data.house = i["house"]
		players.append(gp_data)
		
@rpc("any_peer", "call_local")
func place_orders(orders: Array[Dictionary]):
	if not multiplayer.is_server():
		return
		
	# Save them
	
@rpc("any_peer")
func resolve_order(territory_name: String, params: Dictionary):
	pass
