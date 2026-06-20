extends Node
class_name GameServer

enum Stage { PLANNING, ACTION, BATTLING, BIDDING, MUSTERING, WESTEROS, WILDLING }
enum ActionSubStage { RAIDS, MARCHES, CONSOLIDATES }

# What resumes after an async bidding operation completes.
enum Continuation { NONE, WESTEROS_PHASE }

const IRON_THRONE := 0
const FIEFDOMS    := 1
const KINGS_COURT := 2

var stage: Stage = Stage.PLANNING
var action_sub_stage: ActionSubStage = ActionSubStage.RAIDS
var players: Array[GamePlayerData] = []
var influence_tracks: Array[InfluenceTrack] = []
var orders: Array[Order] = []
var territories: Array[GameTerritory] = []
var current_battle: Battle = null
var round: int = 1
var bids: Dictionary = {}
var bidding_track_index: int = 0
var wildling_strength: int = 2
var wildling_votes: Dictionary = {}

var westeros_deck: WesterosDeck = null
var _westeros_cards: Array = []   # Array[WesterosCard]
var _westeros_idx: int = 0
var _continuation: Continuation = Continuation.NONE

# Pending player choice (Valyrian Blade, kill_unit, etc.).
var _pending_choice: BattleChoice = null
var _pending_choice_player_muster: int = -1

# Queue of BattleChoice objects to process after card reveal effects.
var _choice_queue: Array = []

# Called when _choice_queue drains.
var _after_choices: Callable

# Muster phase — players left to muster (in Iron Throne order)
var _muster_queue: Array[int] = []

var _client_events: ClientEvents

# ── INIT ─────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_client_events = ClientEvents.new()
	add_child(_client_events)

func start_game(players_data: Array) -> void:
	if players_data.size() < 2 or players_data.size() > 6:
		push_error("GameServer: requires 2-6 players")
		return

	for _i in 3:
		influence_tracks.append(InfluenceTrack.new())

	var houses: Array[House] = [
		HouseStark.new(), HouseLannister.new(), HouseBaratheon.new(),
		HouseGreyjoy.new(), HouseTyrell.new(), HouseMartell.new(),
	]

	for i in players_data.size():
		var data = players_data[i]
		var player := GamePlayerData.new()
		player.id = data.id
		player.power = 5
		player.coins = 5
		player.supply = 0
		player.house = houses[i]
		player.initialize_cards()
		players.append(player)
		for track: InfluenceTrack in influence_tracks:
			track.arr.append(player.id)

	for res: TerritoryDataResource in TerritoryDB.all():
		territories.append(GameTerritory.new(res))

	westeros_deck = WesterosDeck.new()
	_update_supply()
	_update_tokens()

	round = 1
	_begin_planning_phase()

# ── HELPERS ───────────────────────────────────────────────────────────────────

func _get_sender_id() -> int:
	var sid := multiplayer.get_remote_sender_id()
	return sid if sid != 0 else multiplayer.get_unique_id()

func get_player(id: int) -> GamePlayerData:
	for p: GamePlayerData in players:
		if p.id == id:
			return p
	return null

func get_territory(id: String) -> GameTerritory:
	for t: GameTerritory in territories:
		if str(t.resource.territory_id) == id:
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

func _get_token_holder_iron_throne() -> GamePlayerData:
	for p: GamePlayerData in players:
		if p.has_iron_throne: return p
	return null

func _get_token_holder_valyrian() -> GamePlayerData:
	for p: GamePlayerData in players:
		if p.has_valyrian_blade: return p
	return null

func _get_token_holder_raven() -> GamePlayerData:
	for p: GamePlayerData in players:
		if p.has_messenger_raven: return p
	return null

# ── TOKENS & SUPPLY ───────────────────────────────────────────────────────────

func _update_tokens() -> void:
	for player: GamePlayerData in players:
		player.has_iron_throne     = (influence_tracks[IRON_THRONE].get_player_at(0) == player.id)
		player.has_valyrian_blade  = (influence_tracks[FIEFDOMS].get_player_at(0)    == player.id)
		player.has_messenger_raven = (influence_tracks[KINGS_COURT].get_player_at(0) == player.id)
		player.valyrian_blade_used = false
		_client_events.player_tokens_updated.rpc(
			player.id, player.has_iron_throne, player.has_valyrian_blade, player.has_messenger_raven
		)

func _update_supply() -> void:
	for player: GamePlayerData in players:
		var supply := 0
		for t: GameTerritory in territories:
			if t.controller == player.id:
				supply += t.resource.supply_count
		player.supply = supply
		_client_events.supply_updated.rpc(player.id, supply)

# ── PLANNING PHASE ────────────────────────────────────────────────────────────

func _begin_planning_phase() -> void:
	stage = Stage.PLANNING
	_update_tokens()
	_client_events.begin_planning.rpc()
	var raven_holder := _get_token_holder_raven()
	if raven_holder:
		_client_events.prompt_messenger_raven.rpc_id(raven_holder.id, -1, [])

@rpc("any_peer", "call_local")
func place_orders(orders_data: Array[Dictionary]) -> void:
	if not multiplayer.is_server(): return
	if stage != Stage.PLANNING: return

	var player := get_player(_get_sender_id())
	if player == null: return

	for t: GameTerritory in territories:
		if t.order and t.order.owner.id == player.id:
			t.order = null
	orders = orders.filter(func(o: Order) -> bool: return o.owner.id != player.id)

	for order_data: Dictionary in orders_data:
		var territory_id: String = order_data.get("territory", "")
		var type_key: String = order_data.get("type", "")
		var t := get_territory(territory_id)
		var order_type := OrderTypes.get_type(type_key)
		if t == null or order_type == null or t.controller != player.id: continue
		var new_order := Order.new()
		new_order.territory = territory_id
		new_order.type = order_type
		new_order.owner = player
		orders.append(new_order)
		t.order = new_order

	_check_all_orders_placed()

@rpc("any_peer", "call_local")
func use_messenger_raven(target_player_id: int, swap_territory: String, new_order_key: String) -> void:
	if not multiplayer.is_server(): return
	if stage != Stage.PLANNING: return
	var sender := get_player(_get_sender_id())
	if sender == null or not sender.has_messenger_raven: return

	var visible: Array[Dictionary] = []
	for o: Order in orders:
		if o.owner.id == target_player_id:
			visible.append({"territory": o.territory, "type": OrderTypes.find_key(o.type)})
	_client_events.prompt_messenger_raven.rpc_id(sender.id, target_player_id, visible)

	if swap_territory != "":
		var t := get_territory(swap_territory)
		var ot := OrderTypes.get_type(new_order_key)
		if t and t.order and t.order.owner.id == sender.id and ot:
			t.order.type = ot

func _check_all_orders_placed() -> void:
	for player: GamePlayerData in players:
		for t: GameTerritory in get_controlled_territories(player.id):
			if t.units.size() > 0 and t.order == null:
				return
	_begin_action_phase()

# ── ACTION PHASE ──────────────────────────────────────────────────────────────

func _begin_action_phase() -> void:
	stage = Stage.ACTION
	action_sub_stage = ActionSubStage.RAIDS

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

@rpc("any_peer", "call_local")
func resolve_order(territory_name: String, params: Dictionary) -> void:
	if not multiplayer.is_server(): return
	if stage != Stage.ACTION: return

	var player := get_player(_get_sender_id())
	if player == null: return

	var order: Order = null
	for o: Order in orders:
		if o.territory == territory_name and o.owner.id == player.id and not o.resolved:
			order = o
			break
	if order == null: return

	var order_type_str := order.type.get_type()
	match action_sub_stage:
		ActionSubStage.RAIDS:
			if order_type_str != OrderType.TYPE_RAID: return
		ActionSubStage.MARCHES:
			if order_type_str != OrderType.TYPE_MARCH: return
		ActionSubStage.CONSOLIDATES:
			if order_type_str != OrderType.TYPE_CONSOLIDATE: return

	if not order.type.is_valid(order, params, self): return
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
	if current_battle != null: return
	match action_sub_stage:
		ActionSubStage.RAIDS:
			var remaining := orders.filter(func(o: Order) -> bool:
				return o.type.get_type() == OrderType.TYPE_RAID and not o.resolved)
			if remaining.is_empty():
				action_sub_stage = ActionSubStage.MARCHES
				_client_events.action_sub_stage_changed.rpc(ActionSubStage.MARCHES)
				_advance_action_sub_stage_if_empty()
		ActionSubStage.MARCHES:
			var remaining := orders.filter(func(o: Order) -> bool:
				return o.type.get_type() == OrderType.TYPE_MARCH and not o.resolved)
			if remaining.is_empty():
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
	if round > 10:
		_end_game()
	else:
		_begin_westeros_phase()

# ── BATTLE SYSTEM ─────────────────────────────────────────────────────────────

func start_battle(attacker: GamePlayerData, territory: GameTerritory,
		attacking_units: Array[Unit], march_bonus: int) -> void:
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

	if battle.defender == null:
		_resolve_battle()
	else:
		_begin_card_selection()

func _begin_card_selection() -> void:
	var battle := current_battle
	_client_events.select_house_card.rpc_id(
		battle.attacker.id, battle.territory.get_id(), battle.attacker.available_card_ids()
	)
	_client_events.select_house_card.rpc_id(
		battle.defender.id, battle.territory.get_id(), battle.defender.available_card_ids()
	)

func _calc_support(player_id: int, battle_territory: GameTerritory) -> int:
	if player_id == -1: return 0
	var total := 0
	for order: Order in orders:
		if order.owner.id != player_id: continue
		if order.type.get_type() != OrderType.TYPE_SUPPORT: continue
		var support_t := get_territory(order.territory)
		if support_t == null or not support_t.is_adjacent_to(battle_territory.get_id()): continue
		var bonus := 0
		if order.type is SupportOrderType:
			bonus = (order.type as SupportOrderType).bonus
		total += support_t.get_attack_strength(battle_territory.get_id()) + bonus
	return total

@rpc("any_peer", "call_local")
func submit_card(card_id: StringName) -> void:
	if not multiplayer.is_server(): return
	if stage != Stage.BATTLING or current_battle == null: return

	var player := get_player(_get_sender_id())
	if player == null: return
	var battle := current_battle

	if player.id == battle.attacker.id and battle.attacker_card == null:
		battle.attacker_card = player.use_card(card_id)
	elif battle.defender != null and player.id == battle.defender.id and battle.defender_card == null:
		battle.defender_card = player.use_card(card_id)

	var atk_ready := battle.attacker_card != null
	var def_ready := battle.defender == null or battle.defender_card != null
	if not (atk_ready and def_ready): return

	battle.run_reveal_effects()  # e.g. Tyrion negates opponent

	var blade_holder := _get_token_holder_valyrian()
	if blade_holder != null and not blade_holder.valyrian_blade_used:
		if blade_holder.id == battle.attacker.id or (battle.defender != null and blade_holder.id == battle.defender.id):
			var choice := ValyrianBladeChoice.new()
			choice.player_id = blade_holder.id
			choice.ctx = {"territory": battle.territory.get_id()}
			_pending_choice = choice
			choice.prompt(_client_events)
			return

	_resolve_battle()

func _resolve_battle() -> void:
	var battle := current_battle
	var atk_str := battle.attacker_strength()
	var def_str := battle.defender_strength()

	var force_atk := battle.attacker_forces_card() and battle.defender != null \
		and battle.defender.house_cards.is_empty() and battle.defender_card == null
	var force_def := battle.defender_forces_card() \
		and battle.attacker.house_cards.is_empty() and battle.attacker_card == null

	var attacker_wins: bool
	if force_atk:
		attacker_wins = true
	elif force_def:
		attacker_wins = false
	elif atk_str != def_str:
		attacker_wins = atk_str > def_str
	else:
		if battle.attacker_wins_ties():
			attacker_wins = true
		elif battle.defender_wins_ties():
			attacker_wins = false
		else:
			var it := _get_token_holder_iron_throne()
			if it != null:
				attacker_wins = (it.id == battle.attacker.id)
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
		atk_str, def_str, attacker_wins
	)

	_choice_queue.clear()
	_choice_queue.append_array(battle.collect_attacker_choices(attacker_wins, self))
	_choice_queue.append_array(battle.collect_defender_choices(attacker_wins, self))

	_after_choices = func(): _finish_battle(battle, attacker_wins)
	_process_next_choice()

func _finish_battle(battle: Battle, attacker_wins: bool) -> void:
	battle.finish_attacker_card(attacker_wins, self)
	battle.finish_defender_card(attacker_wins, self)

	var prevent_def_retreat := battle.attacker_prevents_retreat() and attacker_wins
	var prevent_atk_retreat := battle.defender_prevents_retreat() and not attacker_wins

	if attacker_wins:
		_apply_attacker_wins(battle, prevent_def_retreat)
	else:
		_apply_defender_wins(battle, prevent_atk_retreat)

	current_battle = null
	stage = Stage.ACTION
	_advance_action_sub_stage_if_empty()

func _apply_attacker_wins(battle: Battle, prevent_retreat: bool) -> void:
	var extra_kills := battle.defender_unblocked_swords()
	var survivors := battle.territory.units.duplicate()
	for _i in mini(extra_kills, survivors.size()):
		survivors.pop_back()
	# survivors retreat (TODO: real retreat system); eliminated here for simplicity
	battle.territory.units = []

	for unit: Unit in battle.attacking_units:
		unit.territory = battle.territory.get_id()
		battle.territory.units.append(unit)

	if battle.territory.units.any(func(u: Unit) -> bool: return u.owner == battle.attacker.id):
		battle.territory.controller = battle.attacker.id
		battle.territory.garrison = 0

	notify_territory_changed(battle.territory)

func _apply_defender_wins(battle: Battle, _prevent_retreat: bool) -> void:
	# Attacking survivors retreat (TODO: real retreat system)
	notify_territory_changed(battle.territory)

# ── CHOICE SYSTEM ─────────────────────────────────────────────────────────────

func _process_next_choice() -> void:
	if _choice_queue.is_empty():
		if _after_choices.is_valid():
			_after_choices.call()
		return
	_pending_choice = _choice_queue.pop_front()
	_pending_choice.prompt(_client_events)

@rpc("any_peer", "call_local")
func submit_choice(data: Dictionary) -> void:
	if not multiplayer.is_server(): return
	if _pending_choice == null: return
	var sender := _get_sender_id()
	if sender != _pending_choice.player_id: return

	var choice := _pending_choice
	_pending_choice = null

	var should_continue := choice.apply(self, data)
	if should_continue:
		_process_next_choice()
	# else: the choice launched an async flow (bidding/muster/battle)

# ── BIDDING PHASE ─────────────────────────────────────────────────────────────

func start_bidding(track_index: int) -> void:
	stage = Stage.BIDDING
	bidding_track_index = track_index
	bids.clear()
	_client_events.begin_bidding.rpc(track_index)

@rpc("any_peer", "call_local")
func submit_bid(amount: int) -> void:
	if not multiplayer.is_server(): return
	if stage != Stage.BIDDING: return

	var player := get_player(_get_sender_id())
	if player == null or bids.has(player.id): return

	amount = clampi(amount, 0, player.power)
	player.power -= amount
	bids[player.id] = amount
	_client_events.player_power_updated.rpc(player.id, player.power)

	if bids.size() >= players.size():
		_resolve_bidding()

func _resolve_bidding() -> void:
	influence_tracks[bidding_track_index].reorder(bids)
	_update_tokens()
	var new_order: Array[int] = influence_tracks[bidding_track_index].arr.duplicate()
	_client_events.bidding_resolved.rpc(bidding_track_index, new_order)
	bids.clear()

	match _continuation:
		Continuation.WESTEROS_PHASE:
			_continuation = Continuation.NONE
			stage = Stage.WESTEROS
			_advance_westeros_phase()
		_:
			stage = Stage.ACTION

# ── WESTEROS PHASE ────────────────────────────────────────────────────────────

func _begin_westeros_phase() -> void:
	stage = Stage.WESTEROS
	_westeros_cards = westeros_deck.draw_three()
	var cards_dict: Array[Dictionary] = []
	for c: WesterosCard in _westeros_cards:
		cards_dict.append(c.to_dict())
	_client_events.westeros_phase.rpc(cards_dict)
	_westeros_idx = 0
	_advance_westeros_phase()

func _advance_westeros_phase() -> void:
	if _westeros_idx >= _westeros_cards.size():
		_begin_planning_phase()
		return
	var card: WesterosCard = _westeros_cards[_westeros_idx]
	_westeros_idx += 1
	card.resolve(self)

# ── WILDLING ATTACK ───────────────────────────────────────────────────────────

func _start_wildling_attack() -> void:
	stage = Stage.WILDLING
	wildling_votes.clear()
	_client_events.wildling_attack_started.rpc(wildling_strength)

@rpc("any_peer", "call_local")
func submit_wildling_bid(amount: int) -> void:
	if not multiplayer.is_server(): return
	if stage != Stage.WILDLING: return

	var player := get_player(_get_sender_id())
	if player == null or wildling_votes.has(player.id): return

	amount = clampi(amount, 0, player.power)
	player.power -= amount
	wildling_votes[player.id] = amount
	_client_events.player_power_updated.rpc(player.id, player.power)

	if wildling_votes.size() >= players.size():
		_resolve_wildling()

func _resolve_wildling() -> void:
	var total := 0
	var top_bid := -1
	var top_bidder := -1
	for pid: int in wildling_votes:
		var bid: int = wildling_votes[pid]
		total += bid
		if bid > top_bid:
			top_bid = bid
			top_bidder = pid

	var won := total >= wildling_strength
	if won:
		wildling_strength = 2
		if top_bidder != -1:
			var track := influence_tracks[IRON_THRONE]
			var pos := track.get_position(top_bidder)
			if pos > 0:
				track.arr.remove_at(pos)
				track.arr.insert(pos - 1, top_bidder)
			_update_tokens()
	else:
		wildling_strength += 2
		for p: GamePlayerData in players:
			if not p.house_cards.is_empty():
				p.house_cards.pop_front()

	_client_events.wildling_attack_resolved.rpc(won, top_bidder, wildling_strength)
	wildling_votes.clear()
	stage = Stage.WESTEROS
	_advance_westeros_phase()

# ── MUSTER PHASE ──────────────────────────────────────────────────────────────

func _start_muster_phase() -> void:
	stage = Stage.MUSTERING
	_muster_queue = []
	for p: GamePlayerData in _iron_throne_order():
		_muster_queue.append(p.id)
	_client_events.begin_muster.rpc()
	_continue_muster_phase()

func _continue_muster_phase() -> void:
	while not _muster_queue.is_empty():
		var next_id = _muster_queue.pop_front()
		var player := get_player(next_id)
		if player == null: continue
		var muster_data := _build_muster_data(player)
		if muster_data.is_empty(): continue
		_pending_choice = null  # muster uses submit_muster(), not submit_choice()
		_client_events.prompt_muster.rpc_id(next_id, muster_data)
		_pending_choice_player_muster = next_id
		return
	stage = Stage.WESTEROS
	_advance_westeros_phase()

func _build_muster_data(player: GamePlayerData) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for t: GameTerritory in get_controlled_territories(player.id):
		var pts := t.get_mustering_points()
		if pts <= 0: continue
		var entry: Dictionary = {"territory_id": str(t.get_id()), "mustering_points": pts}
		if t.resource.connected_port != &"":
			entry["port_territory_id"] = str(t.resource.connected_port)
		result.append(entry)
	return result

@rpc("any_peer", "call_local")
func submit_muster(muster_orders: Array[Dictionary]) -> void:
	if not multiplayer.is_server(): return
	if stage != Stage.MUSTERING: return
	var player := get_player(_get_sender_id())
	if player == null or player.id != _pending_choice_player_muster: return
	_pending_choice_player_muster = -1
	_apply_muster_choice(player.id, muster_orders)
	_continue_muster_phase()

func _apply_muster_choice(player_id: int, muster_orders: Array[Dictionary]) -> void:
	var player := get_player(player_id)
	if player == null: return

	var spent: Dictionary = {}

	for mo: Dictionary in muster_orders:
		var tid: String = mo.get("territory", "")
		var unit_type_key: String = mo.get("unit_type", "F")
		var upgrade: bool = mo.get("upgrade", false)

		var t := get_territory(tid)
		if t == null or t.controller != player_id: continue

		var max_pts := t.get_mustering_points()
		var used: int = spent.get(tid, 0)
		var cost := 1 if upgrade else (2 if unit_type_key in ["K", "S", "SE"] else 1)
		if used + cost > max_pts: continue
		spent[tid] = used + cost

		if upgrade:
			var fi := -1
			for i in t.units.size():
				if t.units[i].type_key == "F" and t.units[i].owner == player_id:
					fi = i
					break
			if fi == -1: continue
			t.units.remove_at(fi)

		var new_unit := Unit.new()
		new_unit.territory = tid
		new_unit.owner = player_id
		new_unit.type_key = unit_type_key
		new_unit.type = UnitTypes.get_type(unit_type_key)
		t.units.append(new_unit)

		_client_events.player_mustered.rpc(player_id, tid, unit_type_key)
		notify_territory_changed(t)

# ── VICTORY / END GAME ────────────────────────────────────────────────────────

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

# ── NOTIFICATION HELPERS ──────────────────────────────────────────────────────

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

# ── PRIVATE UTILITIES ─────────────────────────────────────────────────────────

func _get_adjacent_orders(territory_id: String, exclude_owner: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var t := get_territory(territory_id)
	if t == null: return result
	for o: Order in orders:
		if o.owner.id == exclude_owner: continue
		var ot := get_territory(o.territory)
		if ot and ot.is_adjacent_to(territory_id):
			result.append({"territory": o.territory, "type": OrderTypes.find_key(o.type)})
	return result

func _get_player_march_orders(player_id: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for o: Order in orders:
		if o.owner.id == player_id and o.type.get_type() == OrderType.TYPE_MARCH:
			result.append({"territory": o.territory})
	return result

func _remove_orders_of_type(type_str: String) -> void:
	var to_remove := orders.filter(func(o: Order) -> bool: return o.type.get_type() == type_str)
	for o: Order in to_remove:
		var t := get_territory(o.territory)
		if t: t.order = null
	orders = orders.filter(func(o: Order) -> bool: return o.type.get_type() != type_str)
