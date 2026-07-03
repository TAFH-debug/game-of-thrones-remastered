extends Node

# Headless smoke test: drives GameServer directly through start → planning →
# action → westeros. Run: godot --headless res://test/smoke.tscn --quit-after 30

func _ready() -> void:
	print("SMOKE: begin")
	var p1 := PlayerData.new()
	p1.id = 1
	p1.nickname = "Alice"
	var p2 := PlayerData.new()
	p2.id = 2
	p2.nickname = "Bob"

	var game: GameServer = Multiplayer.game
	print("SMOKE: db territories=", TerritoryDB.all().size())
	game.start_game([p1, p2])
	print("SMOKE: players=", game.players.size(), " server territories=", game.territories.size())
	if game.territories.size() > 0:
		print("SMOKE: first territory id='", str(game.territories[0].get_id()), "'")

	var win := game.get_territory("Win")
	print("SMOKE: Win controller=", win.controller, " units=", win.units.size())
	var lpt := game.get_territory("Lpt")
	print("SMOKE: Lpt controller=", lpt.controller, " units=", lpt.units.size())

	var snap := game._build_full_state(1)
	print("SMOKE: snapshot territories=", (snap["territories"] as Array).size(),
		" players=", (snap["players"] as Array).size(), " stage=", snap["stage"])

	# Player 1 (Stark, host) via normal entry point
	var orders1: Array[Dictionary] = [
		{"territory": "Win", "type": "M0"},
		{"territory": "WhH", "type": "C0"},
		{"territory": "TSS", "type": "D1"},
	]
	game.place_orders(orders1)
	print("SMOKE: p1 orders placed, total=", game.orders.size())

	# Player 2 (Lannister) injected directly (can't fake RPC sender id)
	var p2_game := game.get_player(2)
	for entry in [["Lpt", "C0"], ["StS", "D1"], ["TGS", "S0"]]:
		var t := game.get_territory(entry[0])
		var o := Order.new()
		o.territory = entry[0]
		o.type = OrderTypes.get_type(entry[1])
		o.owner = p2_game
		game.orders.append(o)
		t.order = o
	game._check_all_orders_placed()
	print("SMOKE: stage after all orders=", game.stage, " sub=", game.action_sub_stage)

	# March Win -> first adjacent empty land
	var target := ""
	for adj in TerritoryDB.get_territory(&"Win").adjacent_lands:
		var t := game.get_territory(str(adj))
		if t and t.controller == -1 and t.garrison == 0:
			target = str(adj)
			break
	print("SMOKE: marching Win -> ", target)
	if target != "":
		game.resolve_order("Win", {"territory": target, "units": {"F": 1, "K": 1}})
		print("SMOKE: ", target, " controller=", game.get_territory(target).controller,
			" units=", game.get_territory(target).units.size())
	else:
		game.resolve_order("Win", {"territory": ""})

	print("SMOKE: final stage=", game.stage, " sub=", game.action_sub_stage,
		" round=", game.round)
	print("SMOKE OK")
	# No quit() here: let the deferred game_started scene change bring up
	# game.tscn so GameClient renders real state; --quit-after ends the run.
