class_name OrderTokenData
extends Resource

enum OrderTokenType { MARCH, RAID, SUPPORT, CONSOLIDATE_POWER, DEFENSE }

@export var order_type: OrderTokenType
@export var is_special: bool
@export_range(0,2) var defense_modifier: int
@export_range(-1,1) var march_modifier: int

func _init(
	p_order_type: OrderTokenType = OrderTokenType.RAID,
	p_is_special: bool = false,
	p_defense_modifier: int = 0,
	p_march_modifier: int = 0
) -> void:
	order_type = p_order_type
	is_special = p_is_special
	defense_modifier = p_defense_modifier if p_order_type == OrderTokenType.DEFENSE else 0
	march_modifier = p_march_modifier if p_order_type == OrderTokenType.MARCH else 0
