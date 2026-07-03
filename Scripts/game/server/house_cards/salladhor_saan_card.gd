class_name SalladhorSaanHouseCard
extends HouseCard

## If you are being supported, the CS of all non-Baratheon Ships on both sides is reduced to 0.
func on_revealed(battle: Battle, as_attacker: bool, server: GameServer) -> void:
	var my_support := battle.attacker_support if as_attacker else battle.defender_support
	if my_support == 0:
		return
	var atk_id := battle.attacker.id
	var def_id := battle.defender.id if battle.defender != null else -1
	battle.attacker_support = server._calc_support_excl_non_baratheon_ships(atk_id, battle.territory)
	battle.defender_support = server._calc_support_excl_non_baratheon_ships(def_id, battle.territory)
