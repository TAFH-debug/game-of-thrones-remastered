class_name Battle

var attacker: GamePlayerData
var defender: GamePlayerData  # null when fighting a neutral garrison
var territory: GameTerritory
var attacking_units: Array[Unit] = []
var march_bonus: int = 0
var attacker_support: int = 0
var defender_support: int = 0
var attacker_card: HouseCard = null
var defender_card: HouseCard = null

func attacker_strength() -> int:
	var total := march_bonus + attacker_support
	for unit: Unit in attacking_units:
		total += unit.type.get_attack_power(unit, territory.get_id())
	if attacker_card:
		total += attacker_card.combat_strength
	return total

func defender_strength() -> int:
	var total := territory.garrison + territory.defend_bonus + defender_support
	for unit: Unit in territory.units:
		total += unit.type.get_defence_power(unit, territory.get_id())
	if defender_card:
		total += defender_card.combat_strength
	return total

# Returns how many extra casualties the loser takes (unblocked swords)
func attacker_unblocked_swords() -> int:
	var swords := attacker_card.sword_icons if attacker_card else 0
	var forts := defender_card.fortification_icons if defender_card else 0
	return maxi(0, swords - forts)

func defender_unblocked_swords() -> int:
	var swords := defender_card.sword_icons if defender_card else 0
	var forts := attacker_card.fortification_icons if attacker_card else 0
	return maxi(0, swords - forts)
