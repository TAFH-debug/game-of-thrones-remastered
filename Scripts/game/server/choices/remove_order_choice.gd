class_name RemoveOrderChoice
extends BattleChoice

func prompt(events: ClientEvents) -> void:
	events.prompt_card_choice.rpc_id(player_id, BattleChoice.TypeId.REMOVE_ORDER, "", ctx.get("adjacent", []))

func apply(server: GameServer, data: Dictionary) -> bool:
	var target_tid: String = data.get("territory", "")
	var t := server.get_territory(target_tid)
	if t != null and t.order != null and t.order.owner.id != player_id:
		server.orders.erase(t.order)
		t.order = null
	return true
