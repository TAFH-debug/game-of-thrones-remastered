extends Node
class_name ClientEvents

# Server → client event bridge. Every RPC below is invoked by the server and
# re-emitted locally as a signal so client UI can react.

const GAME_SCENE := "res://scenes/game.tscn"

signal on_game_started(assignments: Dictionary)
signal on_full_state(state: Dictionary)
signal on_begin_planning(round_num: int)
signal on_player_orders_submitted(player_id: int)
signal on_reveal_orders(orders: Array)
signal on_action_sub_stage_changed(sub_stage: int)
signal on_player_order_resolve(player_id: int, territory: String)
signal on_territory_updated(territory_id: String, controller: int, garrison: int, units: Array)
signal on_order_raided(raider_id: int, target_territory: String)
signal on_power_consolidated(player_id: int, territory: String, power_gained: int)
signal on_battle_announced(attacker_id: int, defender_id: int, territory: String)
signal on_battle_resolved(attacker_id: int, defender_id: int, territory: String,
	attacker_card: Dictionary, defender_card: Dictionary,
	attacker_strength: int, defender_strength: int, attacker_won: bool)
signal on_begin_bidding(track_index: int)
signal on_bidding_resolved(track_index: int, new_order: Array)
signal on_westeros_phase(cards: Array)
signal on_wildling_attack_started(strength: int)
signal on_wildling_attack_resolved(won: bool, top_bidder_id: int, new_wildling_strength: int)
signal on_supply_updated(player_id: int, supply: int)
signal on_begin_muster()
signal on_player_mustered(player_id: int, territory_id: String, unit_type: String)
signal on_player_power_updated(player_id: int, power: int)
signal on_player_tokens_updated(player_id: int, iron_throne: bool, valyrian: bool, raven: bool)
signal on_game_over(winner_id: int)
signal on_select_house_card(territory: String, available_cards: Array)
signal on_prompt_valyrian_blade(territory: String)
signal on_prompt_card_choice(choice_type: int, territory: String, options: Array)
signal on_prompt_throne_of_blades()
signal on_prompt_messenger_raven(target_player_id: int, visible_orders: Array)
signal on_prompt_muster(muster_data: Array)

# Filled when the server announces game start: player_id -> {house, nickname}
var assignments: Dictionary = {}

# ── BROADCAST events (server → all clients) ─────────────────────────────────

@rpc("authority", "call_local")
func game_started(p_assignments: Dictionary) -> void:
	assignments = p_assignments
	on_game_started.emit(p_assignments)
	get_tree().change_scene_to_file.call_deferred(GAME_SCENE)

@rpc("authority", "call_local")
func begin_planning(round_num: int) -> void:
	on_begin_planning.emit(round_num)

@rpc("authority", "call_local")
func player_orders_submitted(player_id: int) -> void:
	on_player_orders_submitted.emit(player_id)

@rpc("authority", "call_local")
func reveal_orders(orders: Array[Dictionary]) -> void:
	on_reveal_orders.emit(orders)

@rpc("authority", "call_local")
func action_sub_stage_changed(sub_stage: int) -> void:
	on_action_sub_stage_changed.emit(sub_stage)

@rpc("authority", "call_local")
func player_order_resolve(player: int, territory: String) -> void:
	on_player_order_resolve.emit(player, territory)

@rpc("authority", "call_local")
func territory_updated(territory_id: String, controller: int, garrison: int, units: Array[Dictionary]) -> void:
	on_territory_updated.emit(territory_id, controller, garrison, units)

@rpc("authority", "call_local")
func order_raided(raider_id: int, target_territory: String) -> void:
	on_order_raided.emit(raider_id, target_territory)

@rpc("authority", "call_local")
func power_consolidated(player_id: int, territory: String, power_gained: int) -> void:
	on_power_consolidated.emit(player_id, territory, power_gained)

@rpc("authority", "call_local")
func battle_announced(attacker_id: int, defender_id: int, territory: String) -> void:
	on_battle_announced.emit(attacker_id, defender_id, territory)

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
	on_battle_resolved.emit(attacker_id, defender_id, territory,
		attacker_card, defender_card, attacker_strength, defender_strength, attacker_won)

@rpc("authority", "call_local")
func begin_bidding(track_index: int) -> void:
	on_begin_bidding.emit(track_index)

@rpc("authority", "call_local")
func bidding_resolved(track_index: int, new_order: Array[int]) -> void:
	on_bidding_resolved.emit(track_index, new_order)

@rpc("authority", "call_local")
func westeros_phase(cards: Array[Dictionary]) -> void:
	on_westeros_phase.emit(cards)

@rpc("authority", "call_local")
func wildling_attack_started(strength: int) -> void:
	on_wildling_attack_started.emit(strength)

@rpc("authority", "call_local")
func wildling_attack_resolved(won: bool, top_bidder_id: int, new_wildling_strength: int) -> void:
	on_wildling_attack_resolved.emit(won, top_bidder_id, new_wildling_strength)

@rpc("authority", "call_local")
func supply_updated(player_id: int, supply: int) -> void:
	on_supply_updated.emit(player_id, supply)

@rpc("authority", "call_local")
func begin_muster() -> void:
	on_begin_muster.emit()

@rpc("authority", "call_local")
func player_mustered(player_id: int, territory_id: String, unit_type: String) -> void:
	on_player_mustered.emit(player_id, territory_id, unit_type)

@rpc("authority", "call_local")
func player_power_updated(player_id: int, power: int) -> void:
	on_player_power_updated.emit(player_id, power)

@rpc("authority", "call_local")
func player_tokens_updated(player_id: int, iron_throne: bool, valyrian: bool, raven: bool) -> void:
	on_player_tokens_updated.emit(player_id, iron_throne, valyrian, raven)

@rpc("authority", "call_local")
func reveal_westeros_cards(cards: Array[Dictionary]) -> void:
	on_westeros_phase.emit(cards)

@rpc("authority", "call_local")
func game_over(winner_id: int) -> void:
	on_game_over.emit(winner_id)

# ── PRIVATE events (server → specific client) ────────────────────────────────
# call_local lets the server target its own host player via rpc_id.

# Full game state snapshot, sent on request (scene load / reconnect)
@rpc("authority", "call_local")
func full_state(state: Dictionary) -> void:
	on_full_state.emit(state)

# Ask a combatant to choose their house card
@rpc("authority", "call_local")
func select_house_card(territory: String, available_cards: Array[StringName]) -> void:
	on_select_house_card.emit(territory, available_cards)

# Ask Fiefdoms-track leader to use (or skip) the Valyrian Steel Blade
@rpc("authority", "call_local")
func prompt_valyrian_blade(territory: String) -> void:
	on_prompt_valyrian_blade.emit(territory)

# Ask a player to make a post-battle card-ability choice
# choice_type matches BattleChoice.TypeId; options is a list of valid selections
@rpc("authority", "call_local")
func prompt_card_choice(choice_type: int, territory: String, options: Array[Dictionary]) -> void:
	on_prompt_card_choice.emit(choice_type, territory, options)

# Ask the Iron Throne holder to pick Throne of Blades effect
@rpc("authority", "call_local")
func prompt_throne_of_blades() -> void:
	on_prompt_throne_of_blades.emit()

# Ask Messenger Raven holder to act (peek + optionally swap one own order)
# visible_orders: the target player's orders revealed to this player
@rpc("authority", "call_local")
func prompt_messenger_raven(target_player_id: int, visible_orders: Array[Dictionary]) -> void:
	on_prompt_messenger_raven.emit(target_player_id, visible_orders)

# Ask a player to muster units in their territories
# muster_data: Array of {territory_id, mustering_points, port_territory_id?}
@rpc("authority", "call_local")
func prompt_muster(muster_data: Array[Dictionary]) -> void:
	on_prompt_muster.emit(muster_data)
