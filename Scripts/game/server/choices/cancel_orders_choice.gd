class_name CancelOrdersChoice
extends BattleChoice

func prompt(events: ClientEvents) -> void:
	events.prompt_card_choice.rpc_id(player_id, BattleChoice.TypeId.CANCEL_ORDERS, "", _typed_options("orders"))

func apply(server: GameServer, data: Dictionary) -> bool:
	var to_cancel: Array = data.get("territories", [])
	var enemy_id: int = ctx.get("enemy", -1)
	for tid in to_cancel:
		var t := server.get_territory(str(tid))
		if t != null and t.order != null and t.order.owner.id == enemy_id \
				and t.order.type.get_type() == OrderType.TYPE_MARCH:
			server.orders.erase(t.order)
			t.order = null
	return true
