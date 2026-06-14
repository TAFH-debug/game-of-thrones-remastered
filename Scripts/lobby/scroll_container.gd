extends ScrollContainer

@onready var v_scroll_bar = get_v_scroll_bar()

func _ready() -> void:
	v_scroll_bar.changed.connect(_on_scroll_range_changed)

func _on_scroll_range_changed() -> void:
	v_scroll_bar.value = v_scroll_bar.max_value
