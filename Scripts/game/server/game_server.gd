extends Node
class_name GameServer

enum Stage { PLANNING, ACTION, BATTLING, BIDDING, MUSTERING, WESTEROS }
enum ActionSubStage { RAIDS, MARCHES, CONSOLIDATES }

var stage: Stage = Stage.PLANNING
var action_sub_stage: ActionSubStage = ActionSubStage.RAIDS
var players: Array[GamePlayerData] = []
var influence_tracks: Array[InfluenceTrack] = []  # [0]=Iron Throne [1]=Fiefdoms [2]=King's Court
var orders: Array[Order] = []
var territories: Array[GameTerritory] = []
var current_battle: Battle = null
var round: int = 0
var bids: Dictionary = {}
var bidding_track_index: int = 0

const IRON_THRONE := 0
const FIEFDOMS := 1
const KINGS_COURT := 2

var _client_events: ClientEvents

func _ready() -> void:
	_client_events = ClientEvents.new()
	add_child(_client_events)

func start_game(players_data: Array[PlayerData]) -> void:
	if players_data.size() < 2 or players_data.size() > 6:
		push_error("GameServer: requires 2-6 players")
		return

	for _i in 3:
		influence_tracks.append(InfluenceTrack.new())

	for i in players_data.size():
		var data := players_data[i]
		var player := GamePlayerData.new()
		player.id = data.id
		player.power = 5
		player.coins = 5
		player.supply = 0
		player.house = Enums.House.values()[i]
		players.append(player)
		for track: InfluenceTrack in influence_tracks:
			track.arr.append(player.id)

	for res: TerritoryDataResource in TerritoryDB.all():
		territories.append(GameTerritory.new(res))

	stage = Stage.PLANNING
	_client_events.begin_planning.rpc()

# ── HELPERS ─────────────────────────────────────────────────────────────────────

func get_player(id: int) -> GamePlayerData:
	for player: GamePlayerData in players:
		if player.id == id:
			return player
	return null

func get_territory(id: String) -> GameTerritory:
	for t: GameTerritory in territories:
		if t.resource.territory_id == id:
			return t
	return null

func get_controlled_territories(player_id: int) -> Array[GameTerritory]:
	var result: Array[GameTerritory] = []
	for t: GameTerritory in territories:
		if t.controller == player_id:
			result.append(t)
	return result

func _iron_throne_order() -> Array[GamePlayerData]:
	var ordered: Array[GamePlayerData] = []
	for pid: int in influence_tracks[IRON_THRONE].arr:
		var p := get_player(pid)
		if p:
			ordered.append(p)
	return ordered

# ── PLANNING PHASE ──────────────────────────────────────────────────────────────

@rpc("any_peer", "call_local")
func place_orders(orders_data: Array[Dictionary]) -> void:
	if not multiplayer.is_server():
		return
	if stage != Stage.PLANNING:
		return

	var sender_id := multiplayer.get_remote_sender_id()
	var player := get_player(sender_id if sender_id != 0 else multiplayer.get_unique_id())
	if player == null:
		return

	# Remove previous orders for this player
	for t: GameTerritory in territories:
		if t.order and t.order.owner.id == player.id:
			t.order = null
	orders = orders.filter(func(o: Order) -> bool: return o.owner.id != player.id)

	for order_data: Dictionary in orders_data:
		var territory_id: String = order_data.get("territory", "")
		var type_key: String = order_data.get("type", "")
		var t := get_territory(territory_id)
		var order_type := OrderTypes.get_type(type_key)
		if t == null or order_type == null or t.controller != player.id:
			continue
		var new_order := Order.new()
		new_order.territory = territory_id
		new_order.type = order_type
		new_order.owner = player
		orders.append(new_order)
		t.order = new_order

	_check_all_orders_placed()

func _check_all_orders_placed() -> void:
	for player: GamePlayerData in players:
		for t: GameTerritory in get_controlled_territories(player.id):
			if t.units.size() > 0 and t.order == null:
				return
	_begin_action_phase()

func _begin_action_phase() -> void:
	stage = Stage.ACTION
	action_sub_stage = ActionSubStage.RAIDS

	# Apply defend orders immediately so they're active during marches
	_apply_passive_orders(OrderType.TYPE_DEFEND)

	var orders_dict: Array[Dictionary] = []
	for order: Order in orders:
		orders_dict.append({
			"territory": order.territory,
			"type": OrderTypes.find_key(order.type),
			"owner": order.owner.id
		})
	_client_events.reveal_orders.rpc(orders_dict)
	_advance_action_sub_stage_if_empty()

# ── ACTION PHASE ────────────────────────────────────────────────────────────────

@rpc("any_peer", "call_local")
func resolve_order(territory_name: String, params: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	if stage != Stage.ACTION:
		return

	var sender_id := multiplayer.get_remote_sender_id()
	var player := get_player(sender_id if sender_id != 0 else multiplayer.get_unique_id())
	if player == null:
		return

	var order: Order = null
	for o: Order in orders:
		if o.territory == territory_name and o.owner.id == player.id and not o.resolved:
			order = o
			break
	if order == null:
		return

	var order_type_str := order.type.get_type()
	match action_sub_stage:
		ActionSubStage.RAIDS:
			if order_type_str != OrderType.TYPE_RAID:
				return
		ActionSubStage.MARCHES:
			if order_type_str != OrderType.TYPE_MARCH:
				return
		ActionSubStage.CONSOLIDATES:
			if order_type_str != OrderType.TYPE_CONSOLIDATE:
				return

	if not order.type.is_valid(order, params, self):
		return

	order.type.execute(order, params, self)
	order.resolved = true
	_client_events.player_order_resolve.rpc(player.id, territory_name)
	_advance_action_sub_stage_if_empty()

func _apply_passive_orders(type_key: String) -> void:
	for order: Order in orders:
		if order.type.get_type() == type_key and not order.resolved:
			order.type.execute(order, {}, self)
			order.resolved = true

func _advance_action_sub_stage_if_empty() -> void:
	match action_sub_stage:
		ActionSubStage.RAIDS:
			var remaining := orders.filter(func(o: Order) -> bool:
				return o.type.get_type() == OrderType.TYPE_RAID and not o.resolved
			)
			if remaining.is_empty():
				action_sub_stage = ActionSubStage.MARCHES
				_client_events.action_sub_stage_changed.rpc(ActionSubStage.MARCHES)
				_advance_action_sub_stage_if_empty()
		ActionSubStage.MARCHES:
			var remaining := orders.filter(func(o: Order) -> bool:
				return o.type.get_type() == OrderType.TYPE_MARCH and not o.resolved
			)
			if remaining.is_empty() and current_battle == null:
				action_sub_stage = ActionSubStage.CONSOLIDATES
				_apply_passive_orders(OrderType.TYPE_CONSOLIDATE)
				_end_action_phase()
		ActionSubStage.CONSOLIDATES:
			_end_action_phase()

func _end_action_phase() -> void:
	for t: GameTerritory in territories:
		t.clear_order()
	orders.clear()
	round += 1
	if round >= 10:
		_end_game()
	else:
		_begin_planning_phase()

func _begin_planning_phase() -> void:
	stage = Stage.PLANNING
	_client_events.begin_planning.rpc()

# ── BATTLE SYSTEM ────────────────────────────────────────────────────────────────

func start_battle(attacker: GamePlayerData, territory: GameTerritory, attacking_units: Array[Unit], march_bonus: int) -> void:
	var battle := Battle.new()
	battle.attacker = attacker
	battle.defender = get_player(territory.controller) if territory.controller != -1 else null
	battle.territory = territory
	battle.attacking_units = attacking_units
	battle.march_bonus = march_bonus
	battle.attacker_support = _calc_support(attacker.id, territory)
	battle.defender_support = _calc_support(territory.controller, territory) if territory.controller != -1 else 0

	current_battle = battle
	stage = Stage.BATTLING

	_client_events.battle_announced.rpc(attacker.id, territory.controller, territory.get_id())

	# Send available card ids privately to each combatant
	_client_events.select_house_card.rpc_id(attacker.id, territory.get_id(), attacker.available_card_ids())
	if battle.defender:
		_client_events.select_house_card.rpc_id(battle.defender.id, territory.get_id(), battle.defender.available_card_ids())
	else:
		# Garrison battle — resolve immediately with no defender card
		_resolve_battle()

func _calc_support(player_id: int, battle_territory: GameTerritory) -> int:
	var total := 0
	for order: Order in orders:
		if order.owner.id != player_id:
			continue
		if order.type.get_type() != OrderType.TYPE_SUPPORT:
			continue
		var support_t := get_territory(order.territory)
		if support_t == null or not support_t.is_adjacent_to(battle_territory.get_id()):
			continue
		var support_bonus := 0
		if order.type is SupportOrderType:
			support_bonus = (order.type as SupportOrderType).bonus
		total += support_t.get_attack_strength(battle_territory.get_id()) + support_bonus
	return total

@rpc("any_peer", "call_local")
func submit_card(card_id: StringName) -> void:
	if not multiplayer.is_server():
		return
	if stage != Stage.BATTLING or current_battle == null:
		return

	var sender_id := multiplayer.get_remote_sender_id()
	var player := get_player(sender_id if sender_id != 0 else multiplayer.get_unique_id())
	if player == null:
		return

	if player.id == current_battle.attacker.id and current_battle.attacker_card == null:
		current_battle.attacker_card = player.use_card(card_id)
	elif current_battle.defender != null and player.id == current_battle.defender.id and current_battle.defender_card == null:
		current_battle.defender_card = player.use_card(card_id)

	var attacker_ready := current_battle.attacker_card != null
	var defender_ready := current_battle.defender == null or current_battle.defender_card != null
	if attacker_ready and defender_ready:
		_resolve_battle()

func _resolve_battle() -> void:
	var battle := current_battle
	var atk := battle.attacker_strength()
	var def := battle.defender_strength()

	var attacker_wins: bool
	if atk != def:
		attacker_wins = atk > def
	else:
		attacker_wins = influence_tracks[FIEFDOMS].is_higher_than(
			battle.attacker.id,
			battle.defender.id if battle.defender else -1
		)

	_client_events.battle_resolved.rpc(
		battle.attacker.id,
		battle.defender.id if battle.defender else -1,
		battle.territory.get_id(),
		battle.attacker_card.to_dict() if battle.attacker_card else {},
		battle.defender_card.to_dict() if battle.defender_card else {},
		atk, def,
		attacker_wins
	)

	if attacker_wins:
		_apply_attacker_wins(battle)
	else:
		_apply_defender_wins(battle)

	current_battle = null
	stage = Stage.ACTION
	_advance_action_sub_stage_if_empty()

func _apply_attacker_wins(battle: Battle) -> void:
	var extra_kills := battle.defender_unblocked_swords()
	var survivors := battle.territory.units.duplicate()
	for _i in mini(extra_kills, survivors.size()):
		survivors.pop_back()

	battle.territory.units = survivors
	for unit: Unit in battle.attacking_units:
		unit.territory = battle.territory.get_id()
		battle.territory.units.append(unit)

	if battle.territory.units.filter(func(u: Unit) -> bool: return u.owner == battle.attacker.id).size() > 0:
		battle.territory.controller = battle.attacker.id
		battle.territory.garrison = 0

	notify_territory_changed(battle.territory)

func _apply_defender_wins(battle: Battle) -> void:
	# Attacker loses units equal to unblocked swords from defender
	var extra_kills := battle.attacker_unblocked_swords()
	var survivors := battle.attacking_units.duplicate()
	for _i in mini(extra_kills, survivors.size()):
		survivors.pop_back()

	# Survivors retreat — simplified: they return to the source territory if possible
	# For now, they are eliminated if no valid retreat
	notify_territory_changed(battle.territory)

# ── BIDDING PHASE (Clash of Kings) ──────────────────────────────────────────────

func start_bidding(track_index: int) -> void:
	stage = Stage.BIDDING
	bidding_track_index = track_index
	bids.clear()
	_client_events.begin_bidding.rpc(track_index)

@rpc("any_peer", "call_local")
func submit_bid(amount: int) -> void:
	if not multiplayer.is_server():
		return
	if stage != Stage.BIDDING:
		return

	var sender_id := multiplayer.get_remote_sender_id()
	var player := get_player(sender_id if sender_id != 0 else multiplayer.get_unique_id())
	if player == null:
		return

	amount = clampi(amount, 0, player.power)
	player.power -= amount
	bids[player.id] = amount

	if bids.size() >= players.size():
		_resolve_bidding()

func _resolve_bidding() -> void:
	influence_tracks[bidding_track_index].reorder(bids)
	var new_order: Array[int] = influence_tracks[bidding_track_index].arr.duplicate()
	_client_events.bidding_resolved.rpc(bidding_track_index, new_order)
	bids.clear()
	stage = Stage.ACTION

# ── VICTORY / END GAME ──────────────────────────────────────────────────────────

func _count_castles(player_id: int) -> int:
	var count := 0
	for t: GameTerritory in territories:
		if t.controller == player_id and t.has_fortification():
			count += 1
	return count

func _end_game() -> void:
	var best: GamePlayerData = null
	var best_score := 0
	for player: GamePlayerData in players:
		var score := _count_castles(player.id)
		if score > best_score:
			best_score = score
			best = player
	_client_events.game_over.rpc(best.id if best else -1)

# ── NOTIFICATIONS ────────────────────────────────────────────────────────────────

func notify_territory_changed(territory: GameTerritory) -> void:
	var units_dict: Array[Dictionary] = []
	for unit: Unit in territory.units:
		units_dict.append(unit.to_dict())
	_client_events.territory_updated.rpc(
		territory.get_id(), territory.controller, territory.garrison, units_dict
	)

func notify_order_raided(raider: GamePlayerData, target: GameTerritory) -> void:
	_client_events.order_raided.rpc(raider.id, target.get_id())

func notify_consolidate(player: GamePlayerData, territory: GameTerritory, power_gained: int) -> void:
	_client_events.power_consolidated.rpc(player.id, territory.get_id(), power_gained)
