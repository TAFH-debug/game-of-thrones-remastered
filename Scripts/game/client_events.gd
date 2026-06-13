extends Node

@rpc("authority")
func load_game():
	pass
	
@rpc("authority")
func player_order_resolve(player: int, territory: String):
	pass
	
@rpc("authority")
func reveal_orders(orders: Array[Dictionary]):
	pass
	
@rpc("authority")
func reveal_westeros_cards(cards: Array[Dictionary]):
	pass
