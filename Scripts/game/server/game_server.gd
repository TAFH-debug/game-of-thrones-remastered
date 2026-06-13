extends Node
class_name GameServer

enum Stage { PLANNING, ACTION, BATTLING, BIDDING, MUSTERING, WESTEROS }
var stage: Stage = Stage.PLANNING
var players: Array[GamePlayerData] = []
var influence_tracks: Array[InfluenceTrack] = []
var orders: Array[Order] = []
var battling_players: Array[GamePlayerData] = []
var territories: Array[GameTerritory] = []

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
		
	for i in TerritoryDB.all():
		territories.append(GameTerritory.new(i))

func get_player(id: int):
	var player_idx = players.find_custom(func(x): x.id == id)
	return players[player_idx]
	
@rpc("authority")
func setup_game(players: Array[Dictionary]):
	for i in players:
		var gp_data = GamePlayerData.new()
		gp_data.id = i["id"]
		gp_data.house = i["house"]
		players.append(gp_data)
		
@rpc("any_peer", "call_local")
func place_orders(orders_data: Array[Dictionary]):
	if not multiplayer.is_server():
		return
		
	if not stage == Stage.PLANNING:
		return
		
	var player = get_player(multiplayer.get_remote_sender_id())
		
	for order in orders_data:
		var new_order = Order.new()
		new_order.territory = order['territory']
		new_order.type = OrderTypes.get_type(order['type'])
		new_order.owner = player
		orders.append(new_order)
		
@rpc("any_peer", "call_local")
func resolve_order(territory_name: String, params: Dictionary):
	if not multiplayer.is_server():
		return
		
	var player = get_player(multiplayer.get_remote_sender_id())
	
	for order in orders:
		if order.territory == territory_name:
			if order.owner != player:
				return
			if order.type.is_valid(order, params):
				order.type.execute(order, params)
				orders.erase(order)
			break
			
@rpc("any_peer", "call_local")
func submit_card(card_id: int):
	pass
	
@rpc("any_peer", "call_local")
func submit_bid(amount: int):
	pass
