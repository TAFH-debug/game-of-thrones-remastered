extends Node
class_name ClientEvents

# ── BROADCAST events (server → all clients) ─────────────────────────────────

@rpc("authority", "call_local")
func begin_planning() -> void: pass

@rpc("authority", "call_local")
func reveal_orders(orders: Array[Dictionary]) -> void: pass

@rpc("authority", "call_local")
func action_sub_stage_changed(sub_stage: int) -> void: pass

@rpc("authority", "call_local")
func player_order_resolve(player: int, territory: String) -> void: pass

@rpc("authority", "call_local")
func territory_updated(territory_id: String, controller: int, garrison: int, units: Array[Dictionary]) -> void: pass

@rpc("authority", "call_local")
func order_raided(raider_id: int, target_territory: String) -> void: pass

@rpc("authority", "call_local")
func power_consolidated(player_id: int, territory: String, power_gained: int) -> void: pass

@rpc("authority", "call_local")
func battle_announced(attacker_id: int, defender_id: int, territory: String) -> void: pass

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
) -> void: pass

@rpc("authority", "call_local")
func begin_bidding(track_index: int) -> void: pass

@rpc("authority", "call_local")
func bidding_resolved(track_index: int, new_order: Array[int]) -> void: pass

@rpc("authority", "call_local")
func westeros_phase(cards: Array[Dictionary]) -> void: pass

@rpc("authority", "call_local")
func wildling_attack_started(strength: int) -> void: pass

@rpc("authority", "call_local")
func wildling_attack_resolved(won: bool, top_bidder_id: int, new_wildling_strength: int) -> void: pass

@rpc("authority", "call_local")
func supply_updated(player_id: int, supply: int) -> void: pass

@rpc("authority", "call_local")
func begin_muster() -> void: pass

@rpc("authority", "call_local")
func player_mustered(player_id: int, territory_id: String, unit_type: String) -> void: pass

@rpc("authority", "call_local")
func player_power_updated(player_id: int, power: int) -> void: pass

@rpc("authority", "call_local")
func player_tokens_updated(player_id: int, iron_throne: bool, valyrian: bool, raven: bool) -> void: pass

@rpc("authority", "call_local")
func reveal_westeros_cards(cards: Array[Dictionary]) -> void: pass

@rpc("authority", "call_local")
func game_over(winner_id: int) -> void: pass

# ── PRIVATE events (server → specific client) ────────────────────────────────

# Ask a combatant to choose their house card
@rpc("authority")
func select_house_card(territory: String, available_cards: Array[StringName]) -> void: pass

# Ask Fiefdoms-track leader to use (or skip) the Valyrian Steel Blade
@rpc("authority")
func prompt_valyrian_blade(territory: String) -> void: pass

# Ask a player to make a post-battle card-ability choice
# choice_type matches GameServer.ChoiceType; options is a list of valid selections
@rpc("authority")
func prompt_card_choice(choice_type: int, territory: String, options: Array[Dictionary]) -> void: pass

# Ask the Iron Throne holder to pick Throne of Blades effect
@rpc("authority")
func prompt_throne_of_blades() -> void: pass

# Ask Messenger Raven holder to act (peek + optionally swap one own order)
# visible_orders: the target player's orders revealed to this player
@rpc("authority")
func prompt_messenger_raven(target_player_id: int, visible_orders: Array[Dictionary]) -> void: pass

# Ask a player to muster units in their territories
# muster_data: Array of {territory_id, mustering_points, has_port, port_territory_id}
@rpc("authority")
func prompt_muster(muster_data: Array[Dictionary]) -> void: pass
