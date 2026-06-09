extends Node
class_name GameServer

enum Stage { PLANNING, WESTEROS }
var stage: Stage = Stage.PLANNING
var players: Array[GamePlayerData] = []
var influence_tracks: Array[InfluenceTrack] = []

func start_game(players_data: Array[PlayerData]):
	if players_data.size() > 6:
		push_error("This game is for 6 or less players")
		
	for i in range(players_data.size()):
		var data = players_data[i]
		var player = GamePlayerData.new()
		player.id = data.id
		player.coins = 5
		player.supply = 0
		player.house = Enums.House.get(i)
		players.append(player)
	
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
		
	if not stage == Stage.PLANNING:
		return
		
	for order in orders:
		pass
		
	
	
@rpc("any_peer")
func resolve_order(territory_name: String, params: Dictionary):
	if not multiplayer.is_server():
		return
