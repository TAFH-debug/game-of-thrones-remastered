extends CanvasLayer
class_name GameUI

# All in-game HUD and dialogs, built in code. Talks to GameClient only.

const ORDER_KEYS := [
	["M+", "March +1"], ["M0", "March 0"], ["M-", "March -1"],
	["S+", "Support +1"], ["S0", "Support"],
	["R+", "Raid (special)"], ["R0", "Raid"],
	["C+", "Consolidate +1"], ["C0", "Consolidate"],
	["D2", "Defend +2"], ["D1", "Defend +1"],
]

var client: GameClient
var card_catalog: Dictionary = {}   # card id -> HouseCard
var done_players: Dictionary = {}   # pid -> true (orders submitted this round)
var _bid_is_wildling := false

# UI nodes
var top_bar: PanelContainer
var phase_label: Label
var my_stats_label: Label
var submit_btn: Button
var raven_btn: Button
var players_panel: PanelContainer
var players_box: VBoxContainer
var toast_box: VBoxContainer
var targeting_bar: PanelContainer
var targeting_label: Label
var targeting_skip: Button
var dialog: PanelContainer
var dialog_title: Label
var dialog_body: VBoxContainer

func setup(p_client: GameClient) -> void:
	client = p_client

func _ready() -> void:
	_build_catalog()
	_build_hud()

func _build_catalog() -> void:
	var houses: Array = [
		HouseStark.new(), HouseLannister.new(), HouseBaratheon.new(),
		HouseGreyjoy.new(), HouseTyrell.new(), HouseMartell.new(),
	]
	for h in houses:
		for c in h.get_deck():
			card_catalog[str(c.id)] = c

# ── HUD CONSTRUCTION ──────────────────────────────────────────────────────────

func _panel_style(bg := Color(0.08, 0.07, 0.06, 0.85)) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(10)
	sb.border_color = Color(0.55, 0.45, 0.25)
	sb.set_border_width_all(1)
	return sb

func _build_hud() -> void:
	# Top bar
	top_bar = PanelContainer.new()
	top_bar.add_theme_stylebox_override("panel", _panel_style())
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	add_child(top_bar)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 20)
	top_bar.add_child(hb)

	phase_label = Label.new()
	phase_label.text = "Connecting…"
	hb.add_child(phase_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(spacer)

	my_stats_label = Label.new()
	hb.add_child(my_stats_label)

	raven_btn = Button.new()
	raven_btn.text = "🐦 Raven"
	raven_btn.visible = false
	raven_btn.pressed.connect(_open_raven_dialog)
	hb.add_child(raven_btn)

	submit_btn = Button.new()
	submit_btn.text = "Submit Orders"
	submit_btn.visible = false
	submit_btn.pressed.connect(func(): client.submit_orders())
	hb.add_child(submit_btn)

	var menu_btn := Button.new()
	menu_btn.text = "Leave"
	menu_btn.pressed.connect(func(): client.leave_to_menu())
	hb.add_child(menu_btn)

	# Players panel (right side)
	players_panel = PanelContainer.new()
	players_panel.add_theme_stylebox_override("panel", _panel_style())
	players_panel.anchor_left = 1.0
	players_panel.anchor_right = 1.0
	players_panel.anchor_top = 0.5
	players_panel.anchor_bottom = 0.5
	players_panel.offset_left = -300
	players_panel.offset_right = -10
	players_panel.offset_top = -150
	players_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(players_panel)
	players_box = VBoxContainer.new()
	players_panel.add_child(players_box)

	# Toast area (bottom left)
	toast_box = VBoxContainer.new()
	toast_box.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	toast_box.offset_left = 10
	toast_box.offset_top = -300
	toast_box.offset_bottom = -10
	toast_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(toast_box)

	# Targeting bar (bottom center)
	targeting_bar = PanelContainer.new()
	targeting_bar.add_theme_stylebox_override("panel", _panel_style(Color(0.15, 0.1, 0.05, 0.9)))
	targeting_bar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	targeting_bar.offset_top = -70
	targeting_bar.offset_bottom = -15
	targeting_bar.grow_horizontal = Control.GROW_DIRECTION_BOTH
	targeting_bar.visible = false
	add_child(targeting_bar)
	var tb := HBoxContainer.new()
	tb.add_theme_constant_override("separation", 15)
	targeting_bar.add_child(tb)
	targeting_label = Label.new()
	tb.add_child(targeting_label)
	targeting_skip = Button.new()
	targeting_skip.text = "Skip order"
	targeting_skip.pressed.connect(func(): client.skip_current_order())
	tb.add_child(targeting_skip)
	var cancel := Button.new()
	cancel.text = "Cancel"
	cancel.pressed.connect(func(): client._cancel_targeting())
	tb.add_child(cancel)

	# Modal dialog (center)
	dialog = PanelContainer.new()
	dialog.add_theme_stylebox_override("panel", _panel_style(Color(0.1, 0.08, 0.06, 0.97)))
	dialog.set_anchors_preset(Control.PRESET_CENTER)
	dialog.grow_horizontal = Control.GROW_DIRECTION_BOTH
	dialog.grow_vertical = Control.GROW_DIRECTION_BOTH
	dialog.custom_minimum_size = Vector2(420, 0)
	dialog.visible = false
	add_child(dialog)
	var dv := VBoxContainer.new()
	dv.add_theme_constant_override("separation", 10)
	dialog.add_child(dv)
	dialog_title = Label.new()
	dialog_title.add_theme_font_size_override("font_size", 22)
	dv.add_child(dialog_title)
	dialog_body = VBoxContainer.new()
	dialog_body.add_theme_constant_override("separation", 6)
	dv.add_child(dialog_body)

# ── GENERIC HELPERS ───────────────────────────────────────────────────────────

func _open_dialog(title: String) -> VBoxContainer:
	for child in dialog_body.get_children():
		child.queue_free()
	dialog_title.text = title
	dialog.visible = true
	return dialog_body

func close_dialog() -> void:
	dialog.visible = false

func _add_button(parent: Container, text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.pressed.connect(cb)
	parent.add_child(b)
	return b

func _add_label(parent: Container, text: String) -> Label:
	var l := Label.new()
	l.text = text
	parent.add_child(l)
	return l

func toast(msg: String) -> void:
	var l := Label.new()
	l.text = msg
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 6)
	toast_box.add_child(l)
	var tween := create_tween()
	tween.tween_interval(6.0)
	tween.tween_property(l, "modulate:a", 0.0, 1.0)
	tween.tween_callback(l.queue_free)

func _card_label(card_id: String) -> String:
	var c: HouseCard = card_catalog.get(card_id)
	if c == null:
		return card_id.capitalize()
	var s := "%s — STR %d" % [card_id.capitalize(), c.combat_strength]
	if c.sword_icons > 0:
		s += "  ⚔%d" % c.sword_icons
	if c.fortification_icons > 0:
		s += "  🛡%d" % c.fortification_icons
	return s

func mark_player_done(pid: int) -> void:
	done_players[pid] = true

func clear_done_marks() -> void:
	done_players.clear()

# ── REFRESH ───────────────────────────────────────────────────────────────────

func refresh_all() -> void:
	if client == null:
		return
	_refresh_phase()
	_refresh_my_stats()
	_refresh_players()

func _phase_text() -> String:
	match client.stage:
		GameServer.Stage.PLANNING:
			if client.orders_submitted:
				return "Planning — waiting for others"
			return "Planning — place your orders (%d/%d)" % [
				client.local_orders.size(), client.my_unit_territories().size()]
		GameServer.Stage.ACTION:
			match client.sub_stage:
				GameServer.ActionSubStage.RAIDS: return "Action — Raids"
				GameServer.ActionSubStage.MARCHES: return "Action — Marches"
				_: return "Action — Consolidate"
		GameServer.Stage.BATTLING: return "Battle!"
		GameServer.Stage.BIDDING: return "Bidding"
		GameServer.Stage.MUSTERING: return "Mustering"
		GameServer.Stage.WESTEROS: return "Westeros Phase"
		GameServer.Stage.WILDLING: return "Wildling Attack!"
	return ""

func _refresh_phase() -> void:
	phase_label.text = "Round %d/10 — %s" % [client.round_num, _phase_text()]
	submit_btn.visible = client.stage == GameServer.Stage.PLANNING and not client.orders_submitted
	submit_btn.disabled = not client.can_submit_orders()
	raven_btn.visible = client.stage == GameServer.Stage.PLANNING and client.i_have_raven()

func _refresh_my_stats() -> void:
	var me: Dictionary = client.players.get(client.my_id, {})
	var tokens := ""
	if me.get("has_iron_throne", false): tokens += " 👑"
	if me.get("has_valyrian_blade", false): tokens += " 🗡"
	if me.get("has_messenger_raven", false): tokens += " 🐦"
	my_stats_label.text = "House %s  |  Power %d  |  Supply %d%s" % [
		client.my_house().capitalize(), int(me.get("power", 0)), int(me.get("supply", 0)), tokens]

func _refresh_players() -> void:
	for child in players_box.get_children():
		child.queue_free()
	_add_label(players_box, "Players").add_theme_font_size_override("font_size", 20)
	for pid in client.players:
		var p: Dictionary = client.players[pid]
		var tokens := ""
		if p.get("has_iron_throne", false): tokens += "👑"
		if p.get("has_valyrian_blade", false): tokens += "🗡"
		if p.get("has_messenger_raven", false): tokens += "🐦"
		var done := "  ✓" if done_players.get(pid, false) and \
			client.stage == GameServer.Stage.PLANNING else ""
		var l := _add_label(players_box, "%s (%s)  ⚡%d  📦%d %s%s" % [
			client.nickname_of(pid), client.house_of(pid).capitalize(),
			int(p.get("power", 0)), int(p.get("supply", 0)), tokens, done])
		l.add_theme_color_override("font_color", client.house_color(pid))
	if client.tracks.size() >= 3:
		_add_label(players_box, " ")
		for i in 3:
			var names: PackedStringArray = []
			for pid in client.tracks[i]:
				names.append(client.nickname_of(int(pid)))
			_add_label(players_box, "%s: %s" % [client.TRACK_NAMES[i], " > ".join(names)])
	_add_label(players_box, "Wildlings: %d" % client.wildling_strength)

# ── TARGETING BAR ─────────────────────────────────────────────────────────────

func show_targeting_bar(text: String, no_targets: bool) -> void:
	targeting_label.text = text + ("  (no valid targets)" if no_targets else "")
	targeting_bar.visible = true

func hide_targeting_bar() -> void:
	targeting_bar.visible = false

# ── PLANNING DIALOGS ──────────────────────────────────────────────────────────

func show_order_picker(tid: String) -> void:
	var body := _open_dialog("Order for %s" % client.territory_name(tid))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 6)
	body.add_child(grid)
	for entry in ORDER_KEYS:
		var key: String = entry[0]
		_add_button(grid, "%s  %s" % [key, entry[1]], func():
			client.set_local_order(tid, key)
			close_dialog())
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	body.add_child(hb)
	_add_button(hb, "Clear order", func():
		client.set_local_order(tid, "")
		close_dialog())
	_add_button(hb, "Cancel", close_dialog)

func show_march_panel(tid: String, units: Array) -> void:
	var body := _open_dialog("March from %s" % client.territory_name(tid))
	var counts: Dictionary = {}
	for u in units:
		var k := str(u.get("type", "F"))
		counts[k] = int(counts.get(k, 0)) + 1

	var spins: Dictionary = {}
	for k in counts:
		var hb := HBoxContainer.new()
		body.add_child(hb)
		_add_label(hb, "%s (%d available)" % [client.UNIT_NAMES.get(k, k), counts[k]])
		var spin := SpinBox.new()
		spin.min_value = 0
		spin.max_value = counts[k]
		spin.value = counts[k]
		hb.add_child(spin)
		spins[k] = spin

	var hb2 := HBoxContainer.new()
	hb2.add_theme_constant_override("separation", 10)
	body.add_child(hb2)
	_add_button(hb2, "Choose destination", func():
		var selected: Dictionary = {}
		for k in spins:
			var v := int(spins[k].value)
			if v > 0:
				selected[k] = v
		close_dialog()
		if selected.is_empty():
			client.skip_order(tid)
		else:
			client.begin_march_targeting(tid, selected))
	_add_button(hb2, "Skip march", func():
		close_dialog()
		client.skip_order(tid))
	_add_button(hb2, "Cancel", close_dialog)

# ── BATTLE DIALOGS ────────────────────────────────────────────────────────────

func show_card_select(tid: String, cards: Array) -> void:
	var body := _open_dialog("Battle at %s — choose your house card" % client.territory_name(tid))
	for cid in cards:
		var card_id := str(cid)
		_add_button(body, _card_label(card_id), func():
			close_dialog()
			client.submit_card(card_id))

func show_battle_result(atk: int, def: int, tid: String, atk_card: Dictionary,
		def_card: Dictionary, atk_str: int, def_str: int, atk_won: bool) -> void:
	var body := _open_dialog("Battle at %s" % client.territory_name(tid))
	var def_name := client.nickname_of(def) if def != -1 else "Garrison"
	_add_label(body, "%s (%d)  vs  %s (%d)" % [client.nickname_of(atk), atk_str, def_name, def_str])
	if not atk_card.is_empty():
		_add_label(body, "Attacker card: " + _card_label(str(atk_card.get("id", ""))))
	if not def_card.is_empty():
		_add_label(body, "Defender card: " + _card_label(str(def_card.get("id", ""))))
	var winner := client.nickname_of(atk) if atk_won else def_name
	var wl := _add_label(body, "🏆 %s wins!" % winner)
	wl.add_theme_font_size_override("font_size", 20)
	_add_button(body, "OK", close_dialog)
	toast("Battle at %s: %s wins (%d vs %d)" % [client.territory_name(tid), winner, atk_str, def_str])

func show_valyrian_prompt(tid: String) -> void:
	var body := _open_dialog("Valyrian Steel Blade")
	_add_label(body, "Use the blade for +1 sword at %s?" % client.territory_name(tid))
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	body.add_child(hb)
	_add_button(hb, "Use it", func():
		close_dialog()
		client.submit_choice({"use": true}))
	_add_button(hb, "Save it", func():
		close_dialog()
		client.submit_choice({"use": false}))

# ── CARD ABILITY CHOICES ──────────────────────────────────────────────────────

func show_card_choice(choice_type: int, tid: String, options: Array) -> void:
	match choice_type:
		BattleChoice.TypeId.KILL_UNIT:
			var body := _open_dialog("Choose an enemy unit to kill")
			for opt in options:
				var idx := int(opt.get("index", -1))
				var t := str(opt.get("type", "?"))
				_add_button(body, "Kill %s" % client.UNIT_NAMES.get(t, t), func():
					close_dialog()
					client.submit_choice({"unit_index": idx}))
			_add_button(body, "Skip", func():
				close_dialog()
				client.submit_choice({"unit_index": -1}))
		BattleChoice.TypeId.REMOVE_ORDER:
			var body := _open_dialog("Remove an adjacent order")
			for opt in options:
				var t := str(opt.get("territory", ""))
				_add_button(body, "%s [%s]" % [client.territory_name(t), opt.get("type", "")], func():
					close_dialog()
					client.submit_choice({"territory": t}))
			_add_button(body, "Skip", func():
				close_dialog()
				client.submit_choice({"territory": ""}))
		BattleChoice.TypeId.CANCEL_ORDERS:
			var body := _open_dialog("Cancel enemy march orders")
			var checks: Array = []
			for opt in options:
				var t := str(opt.get("territory", ""))
				var cb := CheckBox.new()
				cb.text = client.territory_name(t)
				cb.set_meta("tid", t)
				body.add_child(cb)
				checks.append(cb)
			_add_button(body, "Confirm", func():
				var picked: Array = []
				for cb in checks:
					if cb.button_pressed:
						picked.append(cb.get_meta("tid"))
				close_dialog()
				client.submit_choice({"territories": picked}))
		BattleChoice.TypeId.DORAN_PLAN:
			var body := _open_dialog("Move a player on an influence track")
			var track_opt := OptionButton.new()
			for i in 3:
				track_opt.add_item(client.TRACK_NAMES[i], i)
			body.add_child(track_opt)
			var player_opt := OptionButton.new()
			for pid in client.players:
				player_opt.add_item(client.nickname_of(pid), int(pid))
			body.add_child(player_opt)
			var dir_opt := OptionButton.new()
			dir_opt.add_item("Down (worse)")
			dir_opt.set_item_metadata(0, 1)
			dir_opt.add_item("Up (better)")
			dir_opt.set_item_metadata(1, -1)
			body.add_child(dir_opt)
			_add_button(body, "Confirm", func():
				close_dialog()
				client.submit_choice({
					"track": track_opt.get_selected_id(),
					"player": player_opt.get_selected_id(),
					"direction": int(dir_opt.get_item_metadata(maxi(dir_opt.selected, 0))),
				}))
		BattleChoice.TypeId.RENLY_UPGRADE:
			var body := _open_dialog("Renly: upgrade a footman to a knight?")
			for opt in options:
				var idx := int(opt.get("index", -1))
				_add_button(body, "Upgrade footman #%d" % (idx + 1), func():
					close_dialog()
					client.submit_choice({"unit_index": idx}))
			_add_button(body, "Skip", func():
				close_dialog()
				client.submit_choice({"unit_index": -1}))
		BattleChoice.TypeId.PATCHFACE:
			var body := _open_dialog("Patchface: discard an opponent card")
			for opt in options:
				var cid := str(opt.get("card_id", opt.get("id", "")))
				_add_button(body, _card_label(cid), func():
					close_dialog()
					client.submit_choice({"card_id": cid}))
			_add_button(body, "Skip", func():
				close_dialog()
				client.submit_choice({"card_id": ""}))
		BattleChoice.TypeId.AERON_DAMPHAIR:
			var body := _open_dialog("Aeron Damphair")
			_add_label(body, "Pay 2 power to discard Aeron and play a different card?")
			var hb := HBoxContainer.new()
			hb.add_theme_constant_override("separation", 10)
			body.add_child(hb)
			_add_button(hb, "Yes (-2 power)", func():
				close_dialog()
				client.submit_choice({"swap": true}))
			_add_button(hb, "No", func():
				close_dialog()
				client.submit_choice({"swap": false}))
		_:
			var body := _open_dialog("Choice")
			_add_label(body, "Territory: %s" % tid)
			_add_button(body, "Continue", func():
				close_dialog()
				client.submit_choice({}))

func show_throne_of_blades() -> void:
	var body := _open_dialog("Throne of Blades — choose an effect")
	_add_button(body, "Nothing happens", func():
		close_dialog()
		client.submit_choice({"effect": "nothing"}))
	_add_button(body, "Everyone musters", func():
		close_dialog()
		client.submit_choice({"effect": "muster"}))
	_add_button(body, "Bid: Iron Throne", func():
		close_dialog()
		client.submit_choice({"effect": "clash_iron_throne"}))
	_add_button(body, "Bid: Fiefdoms", func():
		close_dialog()
		client.submit_choice({"effect": "clash_fiefdoms"}))
	_add_button(body, "Bid: King's Court", func():
		close_dialog()
		client.submit_choice({"effect": "clash_kings_court"}))

# ── BIDDING / WILDLING ────────────────────────────────────────────────────────

func show_bid_dialog(track: int) -> void:
	_bid_is_wildling = false
	_build_bid_ui("Bid for the %s track" % client.TRACK_NAMES[track])

func show_wildling_dialog(strength: int) -> void:
	_bid_is_wildling = true
	_build_bid_ui("Wildlings attack with strength %d — bid power to stop them!" % strength)

func _build_bid_ui(title: String) -> void:
	var body := _open_dialog(title)
	var power := client.my_power()
	_add_label(body, "Your power: %d" % power)
	var spin := SpinBox.new()
	spin.min_value = 0
	spin.max_value = power
	spin.value = 0
	body.add_child(spin)
	_add_button(body, "Submit bid", func():
		var amount := int(spin.value)
		close_dialog()
		if _bid_is_wildling:
			client.submit_wildling_bid(amount)
		else:
			client.submit_bid(amount)
		toast("Bid submitted: %d" % amount))

# ── WESTEROS / MUSTER ─────────────────────────────────────────────────────────

func show_westeros_cards(cards: Array) -> void:
	var body := _open_dialog("Westeros Phase")
	for c in cards:
		_add_label(body, "• %s (deck %s)" % [
			str(c.get("name", "?")).capitalize().replace("_", " "), c.get("deck", "?")])
	_add_button(body, "OK", close_dialog)

func show_muster_dialog(muster_data: Array) -> void:
	var body := _open_dialog("Muster new units")
	var orders: Array = []
	var spent: Dictionary = {}
	var list_label := Label.new()
	list_label.text = "(nothing yet)"

	var refresh_list := func():
		var parts: PackedStringArray = []
		for mo in orders:
			var what: String = "F→K" if mo.get("upgrade", false) else str(mo.get("unit_type"))
			parts.append("%s: %s" % [client.territory_name(str(mo.get("territory"))), what])
		list_label.text = "Queued: " + ", ".join(parts) if parts.size() > 0 else "(nothing yet)"

	for entry in muster_data:
		var tid := str(entry.get("territory_id", ""))
		var pts := int(entry.get("mustering_points", 0))
		var port := str(entry.get("port_territory_id", ""))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		body.add_child(row)
		var lbl := _add_label(row, "%s (%d pts)" % [client.territory_name(tid), pts])

		var try_add := func(target: String, unit_type: String, upgrade: bool, cost: int):
			var used := int(spent.get(tid, 0))
			if used + cost > pts:
				toast("Not enough mustering points at %s" % client.territory_name(tid))
				return
			spent[tid] = used + cost
			orders.append({"territory": target, "unit_type": unit_type, "upgrade": upgrade})
			lbl.text = "%s (%d/%d pts)" % [client.territory_name(tid), pts - spent[tid], pts]
			refresh_list.call()

		_add_button(row, "+F", func(): try_add.call(tid, "F", false, 1))
		_add_button(row, "+K", func(): try_add.call(tid, "K", false, 2))
		_add_button(row, "+SE", func(): try_add.call(tid, "SE", false, 2))
		if port != "":
			_add_button(row, "+Ship", func(): try_add.call(port, "S", false, 1))
		_add_button(row, "F→K", func(): try_add.call(tid, "K", true, 1))

	body.add_child(list_label)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	body.add_child(hb)
	_add_button(hb, "Confirm", func():
		close_dialog()
		client.submit_muster(orders))
	_add_button(hb, "Reset", func():
		close_dialog()
		show_muster_dialog(muster_data))
	_add_button(hb, "Muster nothing", func():
		close_dialog()
		client.submit_muster([]))

# ── MESSENGER RAVEN ───────────────────────────────────────────────────────────

func _open_raven_dialog() -> void:
	var body := _open_dialog("Messenger Raven — peek at a player's orders")
	for pid in client.players:
		if pid == client.my_id:
			continue
		_add_button(body, client.nickname_of(pid), func():
			close_dialog()
			client.use_raven_peek(pid))
	_add_button(body, "Cancel", close_dialog)

func show_raven_result(target_pid: int, visible_orders: Array) -> void:
	if target_pid == -1:
		return  # initial planning-phase notification, ignore
	var body := _open_dialog("%s's orders" % client.nickname_of(target_pid))
	if visible_orders.is_empty():
		_add_label(body, "No orders placed yet.")
	for od in visible_orders:
		_add_label(body, "%s: [%s]" % [
			client.territory_name(str(od.get("territory", ""))), od.get("type", "")])
	_add_label(body, " ")
	_add_label(body, "Swap one of your own orders:")
	var terr_opt := OptionButton.new()
	for tid in client.local_orders:
		terr_opt.add_item("%s [%s]" % [client.territory_name(str(tid)), client.local_orders[tid]])
		terr_opt.set_item_metadata(terr_opt.item_count - 1, str(tid))
	body.add_child(terr_opt)
	var order_opt := OptionButton.new()
	for entry in ORDER_KEYS:
		order_opt.add_item("%s  %s" % [entry[0], entry[1]])
		order_opt.set_item_metadata(order_opt.item_count - 1, entry[0])
	body.add_child(order_opt)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	body.add_child(hb)
	_add_button(hb, "Swap", func():
		if terr_opt.selected >= 0:
			var tid := str(terr_opt.get_item_metadata(terr_opt.selected))
			var key := str(order_opt.get_item_metadata(order_opt.selected))
			client.set_local_order(tid, key)
			if client.orders_submitted:
				client.use_raven_swap(tid, key)
		close_dialog())
	_add_button(hb, "Close", close_dialog)

# ── GAME OVER ─────────────────────────────────────────────────────────────────

func show_game_over(winner: int) -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_CENTER)
	vb.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vb.grow_vertical = Control.GROW_DIRECTION_BOTH
	vb.add_theme_constant_override("separation", 20)
	overlay.add_child(vb)
	var title := Label.new()
	if winner == -1:
		title.text = "The game ends with no victor."
	else:
		title.text = "🏆 %s of House %s wins the Iron Throne!" % [
			client.nickname_of(winner), client.house_of(winner).capitalize()]
	title.add_theme_font_size_override("font_size", 36)
	vb.add_child(title)
	_add_button(vb, "Back to menu", func(): client.leave_to_menu())
