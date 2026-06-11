@tool
extends EditorScript

const BOARD_PNG = "res://assets/sprites/map/MapStdRes.webp"
const SCENE_OUT = "res://scenes/board/board.tscn"

const FOG_SCENE = preload("res://scenes/board/board_fog.tscn")
const TERRITORY_SCENE = preload("res://scenes/board/territory/territory.tscn")
const CAMERA_SCENE = preload("res://scenes/systems/camera/drag_camera.tscn")


# Sprite3D.pixel_size = 0.01 (Godot default)
# All coordinates below are pre-scaled for pixel_size = 0.01

func _run():
	if not Engine.is_editor_hint():
		return
		
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path("res://scenes/")):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://scenes/"))

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
	#cam.fov = 90.0
	#cam.zoom_speed = 2.0
	#cam.zoom_min = 3.0
	#cam.zoom_max = 11.0
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
				
		built += 1

	var scene := PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, SCENE_OUT)
	root.queue_free()
	print("saved with %d territories to scene " % built + SCENE_OUT)
