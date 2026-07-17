extends Node

# Verifies baked scenes/game_ui.tscn: all node refs resolve after _ready.
# Run: godot --headless --path . res://test/ui_check.tscn --quit-after 10

func _ready() -> void:
	var ui: GameUI = load("res://scenes/game_ui.tscn").instantiate()
	add_child(ui)
	var refs := {
		"top_bar": ui.top_bar, "phase_label": ui.phase_label,
		"my_stats_label": ui.my_stats_label, "raven_btn": ui.raven_btn,
		"submit_btn": ui.submit_btn, "players_panel": ui.players_panel,
		"players_box": ui.players_box, "toast_box": ui.toast_box,
		"targeting_bar": ui.targeting_bar, "targeting_label": ui.targeting_label,
		"targeting_skip": ui.targeting_skip, "dialog": ui.dialog,
		"dialog_title": ui.dialog_title, "dialog_body": ui.dialog_body,
	}
	var ok := true
	for k in refs:
		if refs[k] == null:
			push_error("missing node ref: " + str(k))
			ok = false
	if ui.card_catalog.is_empty():
		push_error("card catalog empty")
		ok = false
	if ui.dialog != null:
		ui._open_dialog("Test dialog")
		if not ui.dialog.visible:
			push_error("dialog did not open")
			ok = false
		ui.close_dialog()
	print("UI_CHECK ", "OK" if ok else "FAIL")
	get_tree().quit(0 if ok else 1)
