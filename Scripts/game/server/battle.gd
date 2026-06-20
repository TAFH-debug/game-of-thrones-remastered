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

# Valyrian Steel Blade adds +1 sword to one side
var attacker_extra_swords: int = 0
var defender_extra_swords: int = 0

# Tyrion Lannister negates the opponent's card ability text (not stats)
var attacker_card_negated: bool = false
var defender_card_negated: bool = false

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

func attacker_effective_swords() -> int:
	if attacker_card_negated or attacker_card == null:
		return attacker_extra_swords
	return attacker_card.sword_icons + attacker_extra_swords

func defender_effective_swords() -> int:
	if defender_card_negated or defender_card == null:
		return defender_extra_swords
	return defender_card.sword_icons + defender_extra_swords

func attacker_effective_forts() -> int:
	if attacker_card_negated or attacker_card == null:
		return 0
	return attacker_card.fortification_icons

func defender_effective_forts() -> int:
	if defender_card_negated or defender_card == null:
		return 0
	return defender_card.fortification_icons

func attacker_unblocked_swords() -> int:
	return maxi(0, attacker_effective_swords() - defender_effective_forts())

func defender_unblocked_swords() -> int:
	return maxi(0, defender_effective_swords() - attacker_effective_forts())

# ── Template-method wrappers (respect negation, delegate to card) ─────────────

func run_reveal_effects() -> void:
	if attacker_card != null:
		attacker_card.on_revealed(self, true)
	if defender_card != null:
		defender_card.on_revealed(self, false)

func attacker_wins_ties() -> bool:
	return not attacker_card_negated and attacker_card != null and attacker_card.wins_ties()

func defender_wins_ties() -> bool:
	return not defender_card_negated and defender_card != null and defender_card.wins_ties()

func attacker_forces_card() -> bool:
	return not attacker_card_negated and attacker_card != null and attacker_card.forces_card()

func defender_forces_card() -> bool:
	return not defender_card_negated and defender_card != null and defender_card.forces_card()

func attacker_prevents_retreat() -> bool:
	return not attacker_card_negated and attacker_card != null and attacker_card.prevents_retreat()

func defender_prevents_retreat() -> bool:
	return not defender_card_negated and defender_card != null and defender_card.prevents_retreat()

func collect_attacker_choices(attacker_wins: bool, server: GameServer) -> Array:
	if attacker_card_negated or attacker_card == null:
		return []
	return attacker_card.collect_choices(self, true, attacker_wins, server)

func collect_defender_choices(attacker_wins: bool, server: GameServer) -> Array:
	if defender_card_negated or defender_card == null or defender == null:
		return []
	return defender_card.collect_choices(self, false, attacker_wins, server)

func finish_attacker_card(attacker_wins: bool, server: GameServer) -> void:
	if not attacker_card_negated and attacker_card != null:
		attacker_card.on_finish(self, true, attacker_wins, server)

func finish_defender_card(attacker_wins: bool, server: GameServer) -> void:
	if not defender_card_negated and defender_card != null and defender != null:
		defender_card.on_finish(self, false, attacker_wins, server)
