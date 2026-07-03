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

# Extra CS/fort contributions from card on_revealed effects (Stannis, Davos, Theon, etc.)
var attacker_extra_cs: int = 0
var defender_extra_cs: int = 0
var attacker_extra_forts: int = 0
var defender_extra_forts: int = 0

# Victarion: +1 bonus per ship when attacking; Ser Kevan: +1 bonus per footman when attacking
var attacker_ship_attack_bonus: int = 0
var attacker_footmen_attack_bonus: int = 0

# Balon Greyjoy: opponent's house card printed CS becomes 0
var attacker_cs_is_zero: bool = false
var defender_cs_is_zero: bool = false

# Blackfish: owner takes no casualties from swords or card abilities
var attacker_no_casualties: bool = false
var defender_no_casualties: bool = false

# Arianne Martell: attacker wins combat but cannot move units into the territory
var prevent_attacker_advance: bool = false

# Tyrion Lannister (new): fired when Tyrion returns opponent's card; triggers re-prompt
var tyrion_fired: bool = false

# Ser Loras Tyrell: the march order that initiated this battle (for march-again ability)
var march_origin: Order = null

func attacker_strength() -> int:
	var total := march_bonus + attacker_support + attacker_extra_cs
	for unit: Unit in attacking_units:
		var power := unit.type.get_attack_power(unit, territory.get_id())
		if unit.type_key == "S":
			power += attacker_ship_attack_bonus
		elif unit.type_key == "F":
			power += attacker_footmen_attack_bonus
		total += power
	if attacker_card:
		total += 0 if attacker_cs_is_zero else attacker_card.combat_strength
	return total

func defender_strength() -> int:
	var total := territory.garrison + territory.defend_bonus + defender_support + defender_extra_cs
	for unit: Unit in territory.units:
		total += unit.type.get_defence_power(unit, territory.get_id())
	if defender_card:
		total += 0 if defender_cs_is_zero else defender_card.combat_strength
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
		return attacker_extra_forts
	return attacker_card.fortification_icons + attacker_extra_forts

func defender_effective_forts() -> int:
	if defender_card_negated or defender_card == null:
		return defender_extra_forts
	return defender_card.fortification_icons + defender_extra_forts

func attacker_unblocked_swords() -> int:
	return maxi(0, attacker_effective_swords() - defender_effective_forts())

func defender_unblocked_swords() -> int:
	return maxi(0, defender_effective_swords() - attacker_effective_forts())

# ── Template-method wrappers (respect negation, delegate to card) ─────────────

func run_reveal_effects(server: GameServer) -> void:
	if attacker_card != null:
		attacker_card.on_revealed(self, true, server)
	if defender_card != null:
		defender_card.on_revealed(self, false, server)

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

func attacker_prevents_casualties() -> bool:
	return not attacker_card_negated and attacker_card != null and attacker_card.prevents_casualties()

func defender_prevents_casualties() -> bool:
	return not defender_card_negated and defender_card != null and defender_card.prevents_casualties()

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
