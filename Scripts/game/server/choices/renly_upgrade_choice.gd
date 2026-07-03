class_name RenlyUpgradeChoice
extends BattleChoice

func prompt(events: ClientEvents) -> void:
	events.prompt_card_choice.rpc_id(player_id, BattleChoice.TypeId.RENLY_UPGRADE, "", ctx.get("footmen", []))

func apply(server: GameServer, data: Dictionary) -> bool:
	var unit_idx: int = data.get("unit_index", -1)
	var as_attacker: bool = ctx.get("as_attacker", true)
	var battle := server.current_battle
	if battle == null or unit_idx < 0:
		return true
	var units := battle.attacking_units if as_attacker else battle.territory.units
	if unit_idx >= units.size() or units[unit_idx].type_key != "F":
		return true
	units[unit_idx].type_key = "K"
	units[unit_idx].type = UnitTypes.get_type("K")
	server.notify_territory_changed(battle.territory)
	return true
