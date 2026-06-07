class_name OrderTokenData
extends Resource

enum OrderType { MARCH, RAID, SUPPORT, CONSOLIDATE_POWER, DEFEND }

@export var order_type: OrderType
@export var is_special: bool = false
@export_range(0,2) var defense_modifier: int = 0
@export_range(-1,1) var march_modifier: int = 0

func _init(
	p_order_type: OrderType = OrderType.RAID,
	p_is_special: bool = false,
	p_defense_modifier: int = 0,
	p_march_modifier: int = 0
) -> void:
	order_type = p_order_type
	is_special = p_is_special
	defense_modifier = p_defense_modifier
	march_modifier = p_march_modifier
