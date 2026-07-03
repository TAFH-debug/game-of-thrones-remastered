extends Node

# Headless battle smoke test: forces a march into an enemy territory and
# drives the battle through card selection, blade choice and resolution.

func _pick_plain_card(p: GamePlayerData) -> HouseCard:
	for c: HouseCard in p.house_cards:
		if c.get_script() == HouseCard:
			return c
	return p.house_cards[0]

func _ready() -> void:
	print("BATTLE: begin")
	var p1 := PlayerData.new()
	p1.id = 1
	p1.nickname = "Alice"
	var p2 := PlayerData.new()
	p2.id = 2
	p2.nickname = "Bob"

	var game: GameServer = Multiplayer.game
	game.start_game([p1, p2])

	var g1 := game.get_player(1)
	var g2 := game.get_player(2)

	# Give Bob a defended territory adjacent to Winterfell
	var tsh := game.get_territory("TSh")
	tsh.controller = 2
	var def_unit := Unit.new()
	def_unit.territory = "TSh"
	def_unit.owner = 2
	def_unit.type_key = "F"
	def_unit.type = UnitTypes.get_type("F")
	tsh.units.append(def_unit)

	# Force action phase with a single march order for Alice
	game.stage = GameServer.Stage.ACTION
	game.action_sub_stage = GameServer.ActionSubStage.MARCHES
	var o := Order.new()
	o.territory = "Win"
	o.type = OrderTypes.get_type("M0")
	o.owner = g1
	game.orders.append(o)
	game.get_territory("Win").order = o

	game.resolve_order("Win", {"territory": "TSh", "units": {"F": 1, "K": 1}})
	print("BATTLE: stage=", game.stage, " battle=", game.current_battle != null)

	# Alice (attacker, host id 1) submits via normal path
	var atk_card := _pick_plain_card(g1)
	game.submit_card(atk_card.id)
	print("BATTLE: attacker card=", atk_card.id)

	# Bob's card injected directly (can't fake RPC sender)
	var def_card := _pick_plain_card(g2)
	game.current_battle.defender_card = g2.use_card(def_card.id)
	print("BATTLE: defender card=", def_card.id)
	game._check_both_cards_submitted()

	# Valyrian blade prompt goes to fiefdoms leader (Alice) — decline it
	if game._pending_choice != null:
		print("BATTLE: pending choice=", game._pending_choice.get_script().get_global_name())
		game.submit_choice({"use": false})

	print("BATTLE: TSh controller=", tsh.controller, " units=", tsh.units.size(),
		" stage=", game.stage, " battle=", game.current_battle != null)
	print("BATTLE OK")
	get_tree().quit()
