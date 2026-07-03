extends Node3D
class_name GameClient

# Client-side controller for a running match. Mirrors server state received
# through ClientEvents and drives board rendering + input.

const HOUSE_COLORS := {
	"stark":     Color(0.88, 0.9, 0.95),
	"lannister": Color(0.9, 0.18, 0.18),
	"baratheon": Color(0.95, 0.8, 0.12),
	"greyjoy":   Color(0.45, 0.45, 0.55),
	"tyrell":    Color(0.25, 0.75, 0.3),
	"martell":   Color(0.95, 0.55, 0.12),
}

const TRACK_NAMES := ["Iron Throne", "Fiefdoms", "King's Court"]
const UNIT_NAMES := {"F": "Footman", "K": "Knight", "S": "Ship", "SE": "Siege Engine"}

var my_id: int = 1
var ev: ClientEvents
var srv: GameServer

var assignments: Dictionary = {}   # pid -> {house, nickname}
var players: Dictionary = {}       # pid -> {power, supply, house, nickname, tokens}
var terr: Dictionary = {}          # tid -> {controller, garrison, units, order}
var tracks: Array = [[], [], []]
var stage: int = GameServer.Stage.PLANNING
var sub_stage: int = GameServer.ActionSubStage.RAIDS
var round_num: int = 1
var wildling_strength: int = 2
var game_ended: bool = false

# Planning
var local_orders: Dictionary = {}  # tid -> order type key
var orders_submitted: bool = false

# Action targeting
var targeting_source: String = ""
var targeting_kind: String = ""    # "raid" | "march"
var march_units: Dictionary = {}   # type key -> count
var valid_targets: Array = []

var territory_nodes: Dictionary = {}  # tid -> board territory node

@onready var ui: GameUI = $GameUI
@onready var board: Node3D = $Board

func _ready() -> void:
	my_id = multiplayer.get_unique_id()
	srv = Multiplayer.game
	ev = srv.get_client_events()
	assignments = ev.assignments
	_index_territories()
	_connect_events()
	ui.setup(self)
	srv.request_full_state.rpc_id(1)

# ── SETUP ─────────────────────────────────────────────────────────────────────

func _index_territories() -> void:
	for child in board.get_node("Territories").get_children():
		if child.get("data") == null:
			continue
		var tid := str(child.data.territory_id)
		territory_nodes[tid] = child

# Territory clicks are resolved with an explicit physics raycast instead of
# Viewport object picking (which fails to deliver events in this scene).
# A click only counts if the mouse barely moved, so camera drags stay drags.

const CLICK_MAX_DRAG := 12.0

var _press_pos := Vector2.INF
var _pending_click := Vector2.INF

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press_pos = event.position
		elif _press_pos != Vector2.INF:
			if event.position.distance_to(_press_pos) <= CLICK_MAX_DRAG:
				_pending_click = event.position
			_press_pos = Vector2.INF

func _physics_process(_delta: float) -> void:
	if _pending_click == Vector2.INF:
		return
	var pos := _pending_click
	_pending_click = Vector2.INF
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var from := cam.project_ray_origin(pos)
	var query := PhysicsRayQueryParameters3D.create(from, from + cam.project_ray_normal(pos) * 200.0)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var hit := get_viewport().world_3d.direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var territory = (hit["collider"] as Node).get_parent()
	if territory != null and territory.get("data") != null:
		_on_territory_clicked(territory)

func _connect_events() -> void:
	ev.on_full_state.connect(_on_full_state)
	ev.on_begin_planning.connect(_on_begin_planning)
	ev.on_player_orders_submitted.connect(_on_player_orders_submitted)
	ev.on_reveal_orders.connect(_on_reveal_orders)
	ev.on_action_sub_stage_changed.connect(_on_sub_stage_changed)
	ev.on_player_order_resolve.connect(_on_order_resolved)
	ev.on_territory_updated.connect(_on_territory_updated)
	ev.on_order_raided.connect(_on_order_raided)
	ev.on_power_consolidated.connect(_on_power_consolidated)
	ev.on_battle_announced.connect(_on_battle_announced)
	ev.on_battle_resolved.connect(_on_battle_resolved)
	ev.on_begin_bidding.connect(_on_begin_bidding)
	ev.on_bidding_resolved.connect(_on_bidding_resolved)
	ev.on_westeros_phase.connect(_on_westeros_phase)
	ev.on_wildling_attack_started.connect(_on_wildling_started)
	ev.on_wildling_attack_resolved.connect(_on_wildling_resolved)
	ev.on_supply_updated.connect(_on_supply_updated)
	ev.on_begin_muster.connect(_on_begin_muster)
	ev.on_player_mustered.connect(_on_player_mustered)
	ev.on_player_power_updated.connect(_on_power_updated)
	ev.on_player_tokens_updated.connect(_on_tokens_updated)
	ev.on_game_over.connect(_on_game_over)
	ev.on_select_house_card.connect(_on_select_house_card)
	ev.on_prompt_valyrian_blade.connect(_on_prompt_valyrian)
	ev.on_prompt_card_choice.connect(_on_prompt_card_choice)
	ev.on_prompt_throne_of_blades.connect(_on_prompt_throne)
	ev.on_prompt_messenger_raven.connect(_on_prompt_raven)
	ev.on_prompt_muster.connect(_on_prompt_muster)

# ── STATE HELPERS ─────────────────────────────────────────────────────────────

func my_house() -> String:
	return str(assignments.get(my_id, {}).get("house", ""))

func house_of(pid: int) -> String:
	return str(assignments.get(pid, {}).get("house", ""))

func nickname_of(pid: int) -> String:
	return str(assignments.get(pid, {}).get("nickname", "Player %d" % pid))

func house_color(pid: int) -> Color:
	return HOUSE_COLORS.get(house_of(pid), Color.WHITE)

func my_power() -> int:
	return int(players.get(my_id, {}).get("power", 0))

func i_have_raven() -> bool:
	return bool(players.get(my_id, {}).get("has_messenger_raven", false))

func my_unit_territories() -> Array:
	var result: Array = []
	for tid in terr:
		var st: Dictionary = terr[tid]
		if st.get("controller", -1) == my_id and not (st.get("units", []) as Array).is_empty():
			result.append(tid)
	return result

func territory_name(tid: String) -> String:
	var res := TerritoryDB.get_territory(StringName(tid))
	return res.territory_name if res else tid

# ── EVENT HANDLERS ────────────────────────────────────────────────────────────

func _on_full_state(state: Dictionary) -> void:
	stage = int(state.get("stage", 0))
	sub_stage = int(state.get("sub_stage", 0))
	round_num = int(state.get("round", 1))
	wildling_strength = int(state.get("wildling_strength", 2))
	tracks = state.get("tracks", [[], [], []])

	players.clear()
	for pd in state.get("players", []):
		players[int(pd["id"])] = pd
		if not assignments.has(int(pd["id"])):
			assignments[int(pd["id"])] = {
				"house": pd.get("house", ""), "nickname": pd.get("nickname", "")
			}

	terr.clear()
	for td in state.get("territories", []):
		terr[str(td["id"])] = td

	_render_all()
	ui.refresh_all()
	_center_camera_on_home()

var _camera_centered := false

func _center_camera_on_home() -> void:
	if _camera_centered:
		return
	var mine := my_unit_territories()
	if mine.is_empty():
		return
	var cam := board.get_node_or_null("DragCamera") as Camera3D
	var node: Node3D = territory_nodes.get(str(mine[0]))
	if cam == null or node == null:
		return
	_camera_centered = true
	cam.position.x = node.position.x
	cam.position.z = node.position.z + 1.5

func _on_begin_planning(r: int) -> void:
	round_num = r
	stage = GameServer.Stage.PLANNING
	local_orders.clear()
	orders_submitted = false
	_cancel_targeting()
	for tid in terr:
		terr[tid].erase("order")
	ui.clear_done_marks()
	_render_all()
	ui.refresh_all()
	ui.toast("Round %d — Planning. Place orders on your territories." % r)

func _on_player_orders_submitted(pid: int) -> void:
	if pid == my_id:
		orders_submitted = true
	ui.mark_player_done(pid)
	ui.refresh_all()

func _on_reveal_orders(orders: Array) -> void:
	stage = GameServer.Stage.ACTION
	sub_stage = GameServer.ActionSubStage.RAIDS
	local_orders.clear()
	for od in orders:
		var tid := str(od.get("territory", ""))
		if terr.has(tid):
			terr[tid]["order"] = {
				"type": od.get("type", ""), "owner": int(od.get("owner", -1)), "resolved": false
			}
	_render_all()
	ui.refresh_all()
	ui.toast("Orders revealed — Raids first.")

func _on_sub_stage_changed(s: int) -> void:
	sub_stage = s
	_cancel_targeting()
	ui.refresh_all()
	match s:
		GameServer.ActionSubStage.MARCHES: ui.toast("March orders now resolve.")
		GameServer.ActionSubStage.CONSOLIDATES: ui.toast("Consolidating power…")

func _on_order_resolved(_pid: int, tid: String) -> void:
	if terr.has(tid) and terr[tid].has("order"):
		terr[tid]["order"]["resolved"] = true
	_render_territory(tid)

func _on_territory_updated(tid: String, controller: int, garrison: int, units: Array) -> void:
	if not terr.has(tid):
		terr[tid] = {}
	terr[tid]["controller"] = controller
	terr[tid]["garrison"] = garrison
	terr[tid]["units"] = units
	_render_territory(tid)
	ui.refresh_all()

func _on_order_raided(raider: int, tid: String) -> void:
	if terr.has(tid):
		terr[tid].erase("order")
	_render_territory(tid)
	ui.toast("%s raided the order at %s!" % [nickname_of(raider), territory_name(tid)])

func _on_power_consolidated(pid: int, tid: String, gained: int) -> void:
	if players.has(pid):
		players[pid]["power"] = int(players[pid].get("power", 0)) + gained
	ui.refresh_all()
	ui.toast("%s consolidated +%d power at %s" % [nickname_of(pid), gained, territory_name(tid)])

func _on_battle_announced(atk: int, def: int, tid: String) -> void:
	var def_name := nickname_of(def) if def != -1 else "the garrison"
	ui.toast("⚔ %s attacks %s at %s!" % [nickname_of(atk), def_name, territory_name(tid)])

func _on_battle_resolved(atk: int, def: int, tid: String, atk_card: Dictionary,
		def_card: Dictionary, atk_str: int, def_str: int, atk_won: bool) -> void:
	ui.show_battle_result(atk, def, tid, atk_card, def_card, atk_str, def_str, atk_won)

func _on_begin_bidding(track: int) -> void:
	stage = GameServer.Stage.BIDDING
	ui.show_bid_dialog(track)

func _on_bidding_resolved(track: int, new_order: Array) -> void:
	if track >= 0 and track < tracks.size():
		tracks[track] = new_order
	ui.refresh_all()
	var leader := int(new_order[0]) if new_order.size() > 0 else -1
	ui.toast("%s track: %s is now first." % [TRACK_NAMES[track], nickname_of(leader)])

func _on_westeros_phase(cards: Array) -> void:
	stage = GameServer.Stage.WESTEROS
	ui.show_westeros_cards(cards)

func _on_wildling_started(strength: int) -> void:
	stage = GameServer.Stage.WILDLING
	ui.show_wildling_dialog(strength)

func _on_wildling_resolved(won: bool, top: int, new_strength: int) -> void:
	wildling_strength = new_strength
	if won:
		ui.toast("Wildlings repelled! %s led the defense." % nickname_of(top))
	else:
		ui.toast("Wildlings broke through! Strength now %d." % new_strength)
	ui.refresh_all()

func _on_supply_updated(pid: int, supply: int) -> void:
	if players.has(pid):
		players[pid]["supply"] = supply
	ui.refresh_all()

func _on_begin_muster() -> void:
	stage = GameServer.Stage.MUSTERING
	ui.toast("Muster phase — new units are being raised.")
	ui.refresh_all()

func _on_player_mustered(pid: int, tid: String, unit_type: String) -> void:
	ui.toast("%s mustered a %s at %s." % [
		nickname_of(pid), UNIT_NAMES.get(unit_type, unit_type), territory_name(tid)])

func _on_power_updated(pid: int, power: int) -> void:
	if players.has(pid):
		players[pid]["power"] = power
	ui.refresh_all()

func _on_tokens_updated(pid: int, it: bool, vb: bool, mr: bool) -> void:
	if players.has(pid):
		players[pid]["has_iron_throne"] = it
		players[pid]["has_valyrian_blade"] = vb
		players[pid]["has_messenger_raven"] = mr
	ui.refresh_all()

func _on_game_over(winner: int) -> void:
	game_ended = true
	ui.show_game_over(winner)

func _on_select_house_card(tid: String, cards: Array) -> void:
	ui.show_card_select(tid, cards)

func _on_prompt_valyrian(tid: String) -> void:
	ui.show_valyrian_prompt(tid)

func _on_prompt_card_choice(choice_type: int, tid: String, options: Array) -> void:
	ui.show_card_choice(choice_type, tid, options)

func _on_prompt_throne(_a = null) -> void:
	ui.show_throne_of_blades()

func _on_prompt_raven(target_pid: int, visible_orders: Array) -> void:
	ui.show_raven_result(target_pid, visible_orders)

func _on_prompt_muster(muster_data: Array) -> void:
	ui.show_muster_dialog(muster_data)

# ── INPUT ─────────────────────────────────────────────────────────────────────

func _on_territory_clicked(node: Node3D) -> void:
	if game_ended:
		return
	var tid := str(node.data.territory_id)

	if targeting_kind != "":
		# Port hit-shapes overlap their city; accept the land target too.
		if not (tid in valid_targets):
			var res := TerritoryDB.get_territory(StringName(tid))
			if res and res.area_type == TerritoryDataResource.AreaType.PORT \
					and str(res.connected_land) in valid_targets:
				tid = str(res.connected_land)
		if tid in valid_targets:
			_send_target(tid)
		else:
			_cancel_targeting()
		return

	tid = _resolve_click_tid(tid)

	match stage:
		GameServer.Stage.PLANNING:
			if orders_submitted:
				return
			var st: Dictionary = terr.get(tid, {})
			if st.get("controller", -1) != my_id or (st.get("units", []) as Array).is_empty():
				return
			ui.show_order_picker(tid)
		GameServer.Stage.ACTION:
			var order: Dictionary = terr.get(tid, {}).get("order", {})
			if order.is_empty() or int(order.get("owner", -1)) != my_id or order.get("resolved", false):
				return
			var typ := str(order.get("type", ""))
			if sub_stage == GameServer.ActionSubStage.RAIDS and typ.begins_with("R"):
				_begin_raid_targeting(tid)
			elif sub_stage == GameServer.ActionSubStage.MARCHES and typ.begins_with("M"):
				ui.show_march_panel(tid, terr[tid].get("units", []))

# Ports have a fat invisible hit-cylinder that sits above the city polygon and
# eats its clicks. Redirect to the connected land unless the port itself holds
# the player's ships.
func _resolve_click_tid(tid: String) -> String:
	var res := TerritoryDB.get_territory(StringName(tid))
	if res == null or res.area_type != TerritoryDataResource.AreaType.PORT:
		return tid
	for u in (terr.get(tid, {}).get("units", []) as Array):
		if int(u.get("owner", -1)) == my_id:
			return tid
	if res.connected_land != &"":
		return str(res.connected_land)
	return tid

# ── PLANNING ──────────────────────────────────────────────────────────────────

func set_local_order(tid: String, order_key: String) -> void:
	if order_key == "":
		local_orders.erase(tid)
	else:
		local_orders[tid] = order_key
	_render_territory(tid)
	ui.refresh_all()

func can_submit_orders() -> bool:
	if orders_submitted:
		return false
	for tid in my_unit_territories():
		if not local_orders.has(tid):
			return false
	return local_orders.size() > 0

func submit_orders() -> void:
	var arr: Array[Dictionary] = []
	for tid in local_orders:
		arr.append({"territory": str(tid), "type": str(local_orders[tid])})
	srv.place_orders.rpc_id(1, arr)

# ── ACTION TARGETING ──────────────────────────────────────────────────────────

func _adjacent_ids(tid: String) -> Array:
	var res := TerritoryDB.get_territory(StringName(tid))
	if res == null:
		return []
	var result: Array = []
	for a in res.adjacent_lands:
		result.append(str(a))
	for a in res.adjacent_seas:
		result.append(str(a))
	return result

func _begin_raid_targeting(tid: String) -> void:
	targeting_source = tid
	targeting_kind = "raid"
	valid_targets = []
	for adj in _adjacent_ids(tid):
		var st: Dictionary = terr.get(adj, {})
		var order: Dictionary = st.get("order", {})
		if not order.is_empty() and int(order.get("owner", -1)) != my_id:
			valid_targets.append(adj)
	_highlight_targets(true)
	ui.show_targeting_bar("Raid from %s — pick an adjacent enemy order." % territory_name(tid),
		valid_targets.is_empty())

func begin_march_targeting(tid: String, units: Dictionary) -> void:
	targeting_source = tid
	targeting_kind = "march"
	march_units = units
	valid_targets = []
	var has_ship: bool = int(units.get("S", 0)) > 0
	var has_land: bool = int(units.get("F", 0)) > 0 or int(units.get("K", 0)) > 0 \
		or int(units.get("SE", 0)) > 0
	for adj in _adjacent_ids(tid):
		var res := TerritoryDB.get_territory(StringName(adj))
		if res == null:
			continue
		var is_sea := res.area_type != TerritoryDataResource.AreaType.LAND
		if has_ship and not has_land and is_sea:
			valid_targets.append(adj)
		elif has_land and not has_ship and not is_sea:
			valid_targets.append(adj)
	_highlight_targets(true)
	ui.show_targeting_bar("March from %s — pick a destination." % territory_name(tid),
		valid_targets.is_empty())

func skip_current_order() -> void:
	if targeting_source == "":
		return
	srv.resolve_order.rpc_id(1, targeting_source, {"territory": ""})
	_cancel_targeting()

func skip_order(tid: String) -> void:
	srv.resolve_order.rpc_id(1, tid, {"territory": ""})
	if targeting_source == tid:
		_cancel_targeting()

func _send_target(tid: String) -> void:
	if targeting_kind == "raid":
		srv.resolve_order.rpc_id(1, targeting_source, {"territory": tid})
	elif targeting_kind == "march":
		srv.resolve_order.rpc_id(1, targeting_source, {"territory": tid, "units": march_units})
	_cancel_targeting()

func _cancel_targeting() -> void:
	_highlight_targets(false)
	targeting_source = ""
	targeting_kind = ""
	march_units = {}
	valid_targets = []
	ui.hide_targeting_bar()

func _highlight_targets(on: bool) -> void:
	for tid in valid_targets:
		var node = territory_nodes.get(tid)
		if node:
			node.set_selected(on)
	var src = territory_nodes.get(targeting_source)
	if src:
		src.set_selected(on)

# ── RENDERING ─────────────────────────────────────────────────────────────────

func _render_all() -> void:
	for tid in territory_nodes:
		_render_territory(str(tid))

func _render_territory(tid: String) -> void:
	var node = territory_nodes.get(tid)
	if node == null:
		return
	var st: Dictionary = terr.get(tid, {})
	var controller: int = int(st.get("controller", -1))
	var garrison: int = int(st.get("garrison", 0))
	var units: Array = st.get("units", [])

	# Owner banner
	var info = node.get_node_or_null("TerritoryInfo")
	if info != null and info.visible and info.has_method("change_owner"):
		info.change_owner(_owner_display(controller, garrison))

	# Units label
	var unit_label := _get_or_make_label(node, "UnitsLabel", Vector3(0, 0.4, 0.3))
	var parts: PackedStringArray = []
	for u in units:
		parts.append(str(u.get("type", "?")))
	var txt := " ".join(parts)
	if garrison > 0:
		txt = (txt + "  G%d" % garrison).strip_edges()
	unit_label.text = txt
	unit_label.visible = txt != ""
	unit_label.modulate = house_color(controller) if controller != -1 else Color(0.8, 0.8, 0.8)

	# Order token label
	var order_label := _get_or_make_label(node, "OrderLabel", Vector3(0, 0.4, -0.25))
	var order: Dictionary = terr.get(tid, {}).get("order", {})
	var order_txt := ""
	var order_color := Color.WHITE
	if local_orders.has(tid) and stage == GameServer.Stage.PLANNING:
		order_txt = "[%s]" % local_orders[tid]
		order_color = house_color(my_id)
	elif not order.is_empty():
		var owner := int(order.get("owner", -1))
		if stage != GameServer.Stage.PLANNING or owner == my_id:
			order_txt = "[%s]" % order.get("type", "")
			order_color = house_color(owner)
			if order.get("resolved", false):
				order_color.a = 0.35
	order_label.text = order_txt
	order_label.visible = order_txt != ""
	order_label.modulate = order_color

func _owner_display(controller: int, garrison: int) -> StringName:
	if controller == -1:
		return &"Neutral" if garrison > 0 else &"None"
	return StringName(house_of(controller).capitalize())

func _get_or_make_label(node: Node3D, label_name: String, offset: Vector3) -> Label3D:
	var label := node.get_node_or_null(label_name) as Label3D
	if label == null:
		label = Label3D.new()
		label.name = label_name
		label.position = offset
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		label.font_size = 96
		label.outline_size = 24
		label.pixel_size = 0.005
		node.add_child(label)
	return label

# ── SERVER SUBMISSIONS (called from UI) ───────────────────────────────────────

func submit_card(card_id: String) -> void:
	srv.submit_card.rpc_id(1, StringName(card_id))

func submit_choice(data: Dictionary) -> void:
	srv.submit_choice.rpc_id(1, data)

func submit_bid(amount: int) -> void:
	srv.submit_bid.rpc_id(1, amount)

func submit_wildling_bid(amount: int) -> void:
	srv.submit_wildling_bid.rpc_id(1, amount)

func submit_muster(muster_orders: Array) -> void:
	var arr: Array[Dictionary] = []
	for mo in muster_orders:
		arr.append(mo)
	srv.submit_muster.rpc_id(1, arr)

func use_raven_peek(target_pid: int) -> void:
	srv.use_messenger_raven.rpc_id(1, target_pid, "", "")

func use_raven_swap(tid: String, new_order_key: String) -> void:
	srv.use_messenger_raven.rpc_id(1, -1, tid, new_order_key)

func leave_to_menu() -> void:
	Multiplayer.reset()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
