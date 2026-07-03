class_name BattleChoice

## Client-facing type IDs (matches what prompt_card_choice sends as int).
enum TypeId {
	NONE,
	VALYRIAN_BLADE,
	KILL_UNIT,
	REMOVE_ORDER,
	CANCEL_ORDERS,
	DORAN_PLAN,
	THRONE_OF_BLADES,
	RENLY_UPGRADE,
	PATCHFACE,
	AERON_DAMPHAIR,
}

## The player who must respond.
var player_id: int = -1

## Arbitrary context data used by apply() and prompt().
var ctx: Dictionary = {}

## Send the prompt RPC to the waiting player.
func prompt(_events: ClientEvents) -> void:
	pass

## RPC args must match typed parameters exactly; untyped arrays are rejected.
func _typed_options(key: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for opt in ctx.get(key, []):
		result.append(opt)
	return result

## Apply the player's response. Return false if an async flow (bidding/muster/battle) started.
func apply(_server: GameServer, _data: Dictionary) -> bool:
	return true
