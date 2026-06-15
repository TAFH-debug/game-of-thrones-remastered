@tool
extends EditorScript

const BOARD_PNG = "res://assets/sprites/map/MapStdRes.webp"
const SCENE_OUT = "res://scenes/board/board.tscn"
const MESH_OUT_DIR = "res://assets/meshes/territories/"

const FOG_SCENE = preload("res://scenes/board/board_fog.tscn")
const TERRITORY_SCENE = preload("res://scenes/board/territory/territory.tscn")
const CAMERA_SCENE = preload("res://scenes/systems/camera/drag_camera.tscn")


# Sprite3D.pixel_size = 0.01 (Godot default)
# All coordinates below are pre-scaled for pixel_size = 0.01

func _run():
	if not Engine.is_editor_hint():
		return

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://scenes/"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(MESH_OUT_DIR))

	var root := Node3D.new()
	root.name = "Board"
	
	var world_env = WorldEnvironment.new()
	world_env.name = "WorldEnvironment"
	var env = Environment.new()
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	env.background_mode = Environment.BG_SKY
	sky_mat.sky_top_color = Color(1,1,1)
	sky_mat.sky_horizon_color = Color(1.135, 1.152, 1.156)
	sky_mat.ground_bottom_color = Color(0, 0.07, 0.09)
	sky_mat.ground_horizon_color = Color(1.135, 1.152, 1.156)
	sky.sky_material = sky_mat
	env.sky = sky
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_env.environment = env
	root.add_child(world_env)
	world_env.owner = root
	
	var fog := FOG_SCENE.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	fog.name = "BoardFog"
	world_env.add_child(fog)
	fog.owner = root
	
	var cam: Camera3D = CAMERA_SCENE.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	cam.name = "DragCamera"
	cam.position.y = 5.
	cam.rotation.x = deg_to_rad(-80)
	root.add_child(cam)
	cam.owner = root

	var sprite := Sprite3D.new()
	sprite.name = "BoardSprite"
	sprite.pixel_size = 0.01
	sprite.rotation_degrees.x = -90.0
	var board_tex: Texture2D = preload(BOARD_PNG)
	if board_tex:
		sprite.texture = board_tex
	else:
		push_warning("Board PNG not found: " + BOARD_PNG)
	root.add_child(sprite)
	sprite.owner = root
	
	var static_body := StaticBody3D.new()
	static_body.name = "World Boundary"
	static_body.input_ray_pickable = false
	static_body.rotation = Vector3(deg_to_rad(90), 0, 0)
	sprite.add_child(static_body)
	static_body.owner = root
	var world_boundary := CollisionShape3D.new()
	world_boundary.name = "CollisionShape3D"
	world_boundary.shape = WorldBoundaryShape3D.new()
	static_body.add_child(world_boundary)
	world_boundary.owner = root

	var territories_node := Node3D.new()
	territories_node.name = "Territories"
	root.add_child(territories_node)
	territories_node.owner = root

	var built := 0
	#var data := _get_territory_data()
	var data: Dictionary = load("res://scenes/board/territories_dict.gd").new().territory_dict
	for display_name in data.keys():
		if display_name == "Beyond the Wall":
			continue
		
		var entry: Dictionary = data[display_name]
		
		#var territory := Node3D.new()
		var territory = TERRITORY_SCENE.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
		territory.name = str(display_name).replace("'","").to_pascal_case()
		territory.position = Vector3(entry.world_x, 0.0, entry.world_z)
		#territory.rotation_degrees.x = 90.0
		
		var td := TerritoryData.new()
		td.territory_name = str(display_name).replace("_", " ")
		td.territory_id = entry.territory_id
		td.area_type = entry.area_type
		td.fortification = entry.fortification
		td.supply_count = entry.supply_count
		td.power_count = entry.power_count
		td.is_home_area = entry.is_home_area
		td.initial_neutral_force_strength = entry.initial_neutral_force_strength
		td.adjacent_lands.assign(entry.adjacent_lands)
		td.adjacent_seas.assign(entry.adjacent_seas)
		td.connected_port = entry.connected_port
		td.connected_land = entry.connected_land
		
		territory.data = td
		territories_node.add_child(territory)
		territory.owner = root
		
		var area := Area3D.new()
		area.name = "Area3D"
		territory.add_child(area)
		area.owner = root
		
		var polygons: Array = entry.polygons
		if entry.area_type != TerritoryData.AreaType.PORT:
			for i in polygons.size():
				if polygons[i].is_empty():
					push_warning("Empty polygon for: " + display_name)
					continue
				var col := CollisionPolygon3D.new()
				col.name = "CollisionPolygon3D" if i == 0 else "CollisionPolygon3D_%d" % i
				col.polygon = polygons[i]
				col.depth = 0.1
				col.rotation_degrees.x = 90.0
				area.add_child(col)
				col.owner = root
		else:
			var port_col := CollisionShape3D.new()
			var circle: CylinderShape3D = CylinderShape3D.new()
			port_col.name = "CollisionShape3D"
			circle.height = 0.1
			circle.radius = 0.5
			port_col.shape = circle
			port_col.position = Vector3(0, 0.1, 0)
			area.add_child(port_col)
			port_col.owner = root
		
		var st: SurfaceTool = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var mesh_built := false
		if entry.area_type == TerritoryData.AreaType.PORT:
			_build_circle_mesh(st)
			mesh_built = true
		else:
			mesh_built = _build_highlight_mesh(polygons, st)
		if mesh_built:
			var mesh_inst: MeshInstance3D = MeshInstance3D.new()
			mesh_inst.name = "HighlightMesh"
			st.generate_normals()
			st.generate_tangents()
			st.index()
			var committed_mesh: ArrayMesh = st.commit()
			var mesh_path: String = MESH_OUT_DIR + territory.name + "_highlight.res"
			ResourceSaver.save(committed_mesh, mesh_path)
			mesh_inst.mesh = load(mesh_path)
			#mesh_inst.visible = false
			
			var hover_mat: ShaderMaterial = ShaderMaterial.new()
			hover_mat.shader = load("res://shaders/territory_hover.gdshader")
			hover_mat.set_shader_parameter("noise_texture", _make_noise_texture())
			
			var selected_mat: ShaderMaterial = ShaderMaterial.new()
			selected_mat.shader = load("res://shaders/territory_selected.gdshader")

			# Chain them: hover renders first, selected renders as a second pass on top
			hover_mat.next_pass = selected_mat

			mesh_inst.material_override = hover_mat
			#mesh_inst.transparency = 1
			area.add_child(mesh_inst)
			mesh_inst.owner = root
		
		built += 1

	var scene := PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, SCENE_OUT)
	root.queue_free()
	print("saved with %d territories to scene " % built + SCENE_OUT)

func _build_highlight_mesh(polygons: Array, st: SurfaceTool, y_offset: float = 0.05) -> bool:
	var any_success := false
	
	# Compute bounding box across ALL polygons for consistent UV space
	var uv_min := Vector2(INF, INF)
	var uv_max := Vector2(-INF, -INF)
	for poly in polygons:
		for v in poly:
			uv_min = uv_min.min(v)
			uv_max = uv_max.max(v)
	var uv_range: Vector2 = uv_max - uv_min
	if uv_range.x == 0.0: uv_range.x = 1.0
	if uv_range.y == 0.0: uv_range.y = 1.0
	
	st.set_smooth_group(0)  # flat shading
	
	for poly in polygons:
		if poly.size() < 3:
			continue
		#print("%s polygon (%d verts)" % ["convex" if _is_convex(poly) else "concave", poly.size()])
		
		var tris: PackedInt32Array = Geometry2D.triangulate_polygon(poly)
		
		if not tris.is_empty():
			# Normal path: tris is a flat index array [i0, i1, i2, ...]
			for i in range(0, tris.size(), 3):
				_add_flat_vertex(st, poly[tris[i]],   uv_min, uv_range, y_offset)
				_add_flat_vertex(st, poly[tris[i+1]], uv_min, uv_range, y_offset)
				_add_flat_vertex(st, poly[tris[i+2]], uv_min, uv_range, y_offset)
			any_success = true
		else:
			if _triangulate_via_decomposition(poly, st, y_offset, uv_min, uv_range):
				any_success = true
			else:
				push_warning("Could not triangulate polygon with %d verts" % poly.size())
	
	return any_success

func _add_flat_vertex(st: SurfaceTool, v: Vector2, uv_min: Vector2, uv_range: Vector2, y: float) -> void:
	# UV mapped to [0,1] across the polygon's bounding box
	st.set_uv(Vector2((v.x - uv_min.x) / uv_range.x, (v.y - uv_min.y) / uv_range.y))
	st.set_normal(Vector3(0.0, 1.0, 0.0))
	st.set_color(Color.WHITE)
	st.add_vertex(Vector3(v.x, y, v.y))

func _triangulate_via_decomposition(
	poly: PackedVector2Array, 
	st: SurfaceTool,
	y: float, 
	uv_min: Vector2, 
	uv_range: Vector2,
	) -> bool:
	print("triangulate_polygon failed, falling back to decomposition for %d-vert polygon" % poly.size())
	var convex_parts: Array = Geometry2D.decompose_polygon_in_convex(poly)
	
	if convex_parts.is_empty():
		return false
	
	var added_any := false
	for part in convex_parts:
		if part.size() < 3:
			continue
		for i in range(1, part.size() - 1):
			_add_flat_vertex(st, part[0], uv_min, uv_range, y)
			_add_flat_vertex(st, part[i], uv_min, uv_range, y)
			_add_flat_vertex(st, part[i+1], uv_min, uv_range, y)
		added_any = true
	
	return added_any

func _build_circle_mesh(st: SurfaceTool, radius := 0.5, segments := 16, y_offset := 0.05) -> void:
	st.set_smooth_group(0)
	var angle_step: float = 2 * PI / segments
	for i in segments:
		var a0: float = i * angle_step
		var a1: float = (i + 1) * angle_step
		var p0 := Vector2(cos(a0), sin(a0))
		var p1 := Vector2(cos(a1), sin(a1))
		# UV: remap [-1,1] → [0,1]
		# CCW winding (matches polygon mesh), viewed from +Y
		st.set_uv(Vector2(0.5, 0.5));
		st.set_normal(Vector3(0,1,0)); st.set_color(Color.WHITE);
		st.add_vertex(Vector3(0.0, y_offset, 0.0))
		st.set_uv((Vector2(p1.x, p1.y) + Vector2.ONE) * 0.5);
		st.set_normal(Vector3(0,1,0)); st.set_color(Color.WHITE);
		st.add_vertex(Vector3(p1.x * radius, y_offset, p1.y * radius))
		st.set_uv((Vector2(p0.x, p0.y) + Vector2.ONE) * 0.5);
		st.set_normal(Vector3(0,1,0)); st.set_color(Color.WHITE);
		st.add_vertex(Vector3(p0.x * radius, y_offset, p0.y * radius))
		
func _is_convex(poly: PackedVector2Array) -> bool:
	var n := poly.size()
	var sign := 0
	for i in n:
		var a: Vector2 = poly[i]
		var b: Vector2 = poly[(i + 1) % n]
		var c: Vector2 = poly[(i + 2) % n]
		var cross := (b - a).cross(c - b)
		if cross != 0.0:
			var s := 1 if cross > 0 else -1
			if sign == 0:
				sign = s
			elif sign != s:
				return false
	return true

func _make_noise_texture() -> NoiseTexture2D:
	var noise_tex := NoiseTexture2D.new()
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.08
	noise_tex.noise = noise
	noise_tex.width = 256
	noise_tex.height = 256
	noise_tex.seamless = true
	return noise_tex
