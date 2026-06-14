extends Node
class_name ClientEvents

# All RPCs here are authority→clients only (server pushes state to clients)

@rpc("authority", "call_local")
func begin_planning() -> void:
	pass

@rpc("authority", "call_local")
func reveal_orders(orders: Array[Dictionary]) -> void:
	pass

@rpc("authority", "call_local")
func action_sub_stage_changed(sub_stage: int) -> void:
	pass

@rpc("authority", "call_local")
func player_order_resolve(player: int, territory: String) -> void:
	pass

@rpc("authority", "call_local")
func territory_updated(territory_id: String, controller: int, garrison: int, units: Array[Dictionary]) -> void:
	pass

@rpc("authority", "call_local")
func order_raided(raider_id: int, target_territory: String) -> void:
	pass

@rpc("authority", "call_local")
func power_consolidated(player_id: int, territory: String, power_gained: int) -> void:
	pass

# Broadcast: all players learn a battle started
@rpc("authority", "call_local")
func battle_announced(attacker_id: int, defender_id: int, territory: String) -> void:
	pass

# Private: sent only to the combatant who must pick a card
@rpc("authority")
func select_house_card(territory: String, available_cards: Array[StringName]) -> void:
	pass

@rpc("authority", "call_local")
func battle_resolved(
	attacker_id: int,
	defender_id: int,
	territory: String,
	attacker_card: Dictionary,
	defender_card: Dictionary,
	attacker_strength: int,
	defender_strength: int,
	attacker_won: bool
) -> void:
	pass

@rpc("authority", "call_local")
func begin_bidding(track_index: int) -> void:
	pass

@rpc("authority", "call_local")
func bidding_resolved(track_index: int, new_order: Array[int]) -> void:
	pass

@rpc("authority", "call_local")
func reveal_westeros_cards(cards: Array[Dictionary]) -> void:
	pass

@rpc("authority", "call_local")
func game_over(winner_id: int) -> void:
	pass
