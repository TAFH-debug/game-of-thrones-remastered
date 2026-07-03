extends Node

# Survives scene changes (lives on root). Prints game state once per second.
# In the game scene: simulates a click on an owned territory, checks the
# order dialog opened, and saves a screenshot.

const SHOT_DIR := "C:/Users/TIMING.KZ/AppData/Local/Temp/claude/C--Users-TIMING-KZ-Desktop-projects-games-game-of-thrones-remastered/5826a7a9-6e34-4bb1-bc05-34d009c81a21/scratchpad"

var tag := "?"
var _t := 0.0
var _game_ticks := 0
var _clicked := false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print(tag, " PROBE: _input mousebtn pressed=", event.pressed, " pos=", event.position)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print(tag, " PROBE: _unhandled mousebtn pressed=", event.pressed, " pos=", event.position)

func _process(delta: float) -> void:
	_t += delta
	if _t < 1.0:
		return
	_t = 0.0
	var cs := get_tree().current_scene
	if cs is GameClient:
		_game_ticks += 1
		print(tag, " PROBE: scene=Game my_id=", cs.my_id, " stage=", cs.stage,
			" terr=", cs.terr.size(), " mine=", cs.my_unit_territories().size(),
			" dialog=", cs.ui.dialog.visible, " local_orders=", cs.local_orders)
		if _game_ticks == 3 and not _clicked:
			_clicked = true
			_click_own_territory(cs)
	else:
		print(tag, " PROBE: scene=", cs.name if cs else "none",
			" lobby_players=", Multiplayer.lobby.players.size())

func _click_own_territory(cs: GameClient) -> void:
	var mine := cs.my_unit_territories()
	if mine.is_empty():
		print(tag, " PROBE: no own territories to click!")
		return
	var tid := str(mine[0])
	var node: Node3D = cs.territory_nodes[tid]
	var cam := cs.get_viewport().get_camera_3d()
	if cam == null:
		print(tag, " PROBE: no camera!")
		return
	var pos := cam.unproject_position(node.global_position)
	print(tag, " PROBE: clicking ", tid, " at screen ", pos)

	_dump_controls_at(get_tree().root, pos)

	var from := cam.project_ray_origin(pos)
	var query := PhysicsRayQueryParameters3D.create(from, from + cam.project_ray_normal(pos) * 200.0)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var hit := cs.get_viewport().world_3d.direct_space_state.intersect_ray(query)
	if hit.is_empty():
		print(tag, " PROBE: ray hit NOTHING (node pos=", node.global_position, ")")
	else:
		print(tag, " PROBE: ray hit parent=", (hit["collider"] as Node).get_parent().name)

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = pos
	press.global_position = pos
	get_tree().root.push_input(press)
	var release: InputEventMouseButton = press.duplicate()
	release.pressed = false
	get_tree().root.push_input(release)

	await get_tree().create_timer(0.5).timeout
	print(tag, " PROBE: after click dialog_visible=", cs.ui.dialog.visible,
		" local_orders=", cs.local_orders)
	await RenderingServer.frame_post_draw
	var img := cs.get_viewport().get_texture().get_image()
	img.save_png("%s/%s_after_click.png" % [SHOT_DIR, tag.to_lower()])
	print(tag, " PROBE: screenshot saved")

func _dump_controls_at(n: Node, pos: Vector2) -> void:
	if n is Control and n.is_visible_in_tree() and n.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		if n.get_global_rect().has_point(pos):
			print(tag, " PROBE: control at point: ", n.get_path(), " filter=", n.mouse_filter,
				" rect=", n.get_global_rect())
	for child in n.get_children():
		_dump_controls_at(child, pos)
