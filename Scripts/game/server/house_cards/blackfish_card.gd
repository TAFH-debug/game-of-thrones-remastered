class_name BlackfishHouseCard
extends HouseCard

## Owner takes no casualties from sword icons, card abilities, or Tides of Battle.
func prevents_casualties() -> bool:
	return true
