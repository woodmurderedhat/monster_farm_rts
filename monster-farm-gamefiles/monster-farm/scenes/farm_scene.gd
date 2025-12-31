extends Node2D
## Farm scene controller

@onready var buildings = $Buildings
@onready var resources = $Resources
@onready var monsters = $Monsters
@onready var farm_panel = $FarmUI/FarmPanel

@export var max_monsters_to_spawn: int = 6

var farm_manager: FarmManager
var assembler: MonsterAssembler
var building_defs: Array = []
var built_structures: Array = []
var build_options: Array = []
var pending_build_def: Dictionary = {}
var is_placing: bool = false

func _ready():
	GameState.change_state(GameState.State.FARM_SIMULATION)
	_assign_systems()
	_load_building_definitions()
	_load_build_options()
	load_farm()
	setup_buildings()
	setup_monsters()
	_refresh_farm_ui()

func _assign_systems():
	assembler = get_node_or_null("/root/GameWorld/MonsterAssembler")
	if not assembler:
		assembler = MonsterAssembler.new()

	farm_manager = get_node_or_null("/root/GameWorld/FarmManager")
	if not farm_manager:
		farm_manager = FarmManager.new()
		add_child(farm_manager)

func load_farm():
	if GameState and GameState.current_farm:
		var farm_data = GameState.current_farm
		print("Loading farm: %s" % farm_data.get("name", "Farm"))
		if farm_panel:
			farm_panel.set_farm_data(farm_data)
			farm_panel.set_resources(farm_data.get("resources", {}))
			farm_panel.build_requested.connect(_on_build_requested)

func _load_building_definitions():
	building_defs.clear()
	if GameState and GameState.current_farm and GameState.current_farm.has("unlocked_buildings"):
		for entry in GameState.current_farm.get("unlocked_buildings", []):
			var def := _resolve_building_definition(entry)
			if not def.is_empty():
				building_defs.append(def)

	if building_defs.is_empty():
		building_defs = [
			{"id": "rest_house", "display_name": "Rest House", "job_type_id": "job_rest", "position": Vector2(100, 100)},
			{"id": "feeding_station", "display_name": "Feeding Station", "job_type_id": "job_feed", "position": Vector2(200, 100)},
			{"id": "training_arena", "display_name": "Training Arena", "job_type_id": "job_train", "position": Vector2(300, 100)},
			{"id": "defense_tower", "display_name": "Defense Tower", "job_type_id": "job_defend", "position": Vector2(400, 100)}
		]
	build_options = building_defs.duplicate()

func _load_build_options():
	# Load all known building resources to expose in build menu
	var options: Array = []
	var dir := DirAccess.open("res://data/buildings/")
	if dir:
		dir.list_dir_begin()
		var fn := dir.get_next()
		while fn != "":
			if fn.ends_with(".tres") and fn.begins_with("building_"):
				var res_path := "res://data/buildings/%s" % fn
				var res := load(res_path)
				if res:
					options.append({
						"id": res.get("id", fn.get_basename()),
						"display_name": res.get("display_name", fn.get_basename()),
						"job_type_id": res.get("job_type_id", "job_build"),
						"position": res.get("default_position", Vector2.ZERO)
					})
			fn = dir.get_next()

	if not options.is_empty():
		build_options = options

func setup_buildings():
	built_structures.clear()
	for def in building_defs:
		var building = create_building(def.get("display_name", "Structure"), def.get("position", Vector2.ZERO))
		building.set_meta("id", def.get("id", ""))
		building.set_meta("job_type_id", def.get("job_type_id", ""))
		buildings.add_child(building)
		built_structures.append(building)
		if farm_manager:
			farm_manager.structures.append(building)
			var job_type_id: String = def.get("job_type_id", "")
			if not job_type_id.is_empty():
				farm_manager.post_job(job_type_id, building.global_position, {"structure_id": def.get("id", "")})
	if farm_panel:
		farm_panel.set_build_options(build_options)

func create_building(building_name: String, pos: Vector2) -> Node2D:
	var building = Node2D.new()
	building.position = pos
	building.name = building_name

	var sprite = Sprite2D.new()
	var color = Color.GRAY
	sprite.texture = _create_building_texture(color, 64, 64)
	building.add_child(sprite)

	var label = Label.new()
	label.text = building_name
	label.modulate = Color.WHITE
	building.add_child(label)

	return building

func _create_building_texture(color: Color, w: int, h: int) -> Texture2D:
	var image = Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in range(h):
		for x in range(w):
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)

func setup_monsters():
	if not GameState:
		return

	var positions = [Vector2(100, 300), Vector2(150, 300), Vector2(200, 300), Vector2(250, 300), Vector2(300, 300), Vector2(350, 300)]
	for i in range(min(GameState.owned_monsters.size(), max_monsters_to_spawn)):
		var dna_stack = GameState.owned_monsters[i]
		var spawned = assembler.assemble_monster(dna_stack, MonsterAssembler.SpawnContext.FARM)
		if spawned:
			spawned.position = positions[i % positions.size()]
			spawned.set_meta("team", 0)
			monsters.add_child(spawned)
			if farm_manager:
				farm_manager.register_monster(spawned)

func _refresh_farm_ui():
	if not farm_panel:
		return
	farm_panel.set_monsters(monsters.get_children())
	farm_panel.set_stats(farm_manager.get_stats() if farm_manager else {})
	farm_panel.set_resources(GameState.current_farm.get("resources", {}) if GameState and GameState.current_farm else {})
	farm_panel.set_buildings(building_defs)
	farm_panel.set_build_options(build_options)

func _on_build_requested(building_id: String):
	var def := _resolve_building_definition(building_id)
	if def.is_empty():
		return
	if not _can_afford(def.get("cost", {})):
		print("Not enough resources to build %s" % def.get("display_name", building_id))
		return
	var placement_type: String = def.get("placement_type", "structure")
	if placement_type in ["wall", "gate", "trap"]:
		var pos := def.get("position", _compute_build_position(def))
		pos = _snap_position(def, pos)
		if _is_overlapping(pos):
			print("Cannot place %s; overlaps another structure" % def.get("display_name", building_id))
			return
		_finalize_build(def, pos)
	else:
		pending_build_def = def
		is_placing = true
		print("Click to place %s" % def.get("display_name", building_id))

func _unhandled_input(event):
	if not is_placing:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_placing = false
			pending_build_def.clear()
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			var pos := _snap_position(pending_build_def, event.position)
			if _is_overlapping(pos):
				print("Cannot place %s; overlaps another structure" % pending_build_def.get("display_name", pending_build_def.get("id", "")))
				return
			_finalize_build(pending_build_def, pos)
			pending_build_def.clear()
			is_placing = false

func _compute_build_position(def: Dictionary) -> Vector2:
	var placement_type: String = def.get("placement_type", "structure")
	var base_pos: Vector2 = def.get("position", def.get("default_position", Vector2(120, 140)))
	var step: Vector2 = def.get("snap_step", Vector2(40, 0))
	if placement_type in ["wall", "gate", "trap"]:
		var idx := built_structures.size()
		return Vector2(base_pos.x + step.x * idx, base_pos.y)
	return base_pos + Vector2(step.x * built_structures.size(), step.y * built_structures.size())

func _snap_position(def: Dictionary, pos: Vector2) -> Vector2:
	var snapped := pos
	var step: Vector2 = def.get("snap_step", Vector2.ZERO)
	if step.x != 0:
		snapped.x = round(pos.x / step.x) * step.x
	if step.y != 0:
		snapped.y = round(pos.y / step.y) * step.y
	# For fixed-lane placements, lock Y if provided
	if def.has("position"):
		snapped.y = def.get("position").y
	return snapped

func _can_afford(cost: Dictionary) -> bool:
	if cost.is_empty():
		return true
	if not GameState or not GameState.current_farm:
		return false
	var res: Dictionary = GameState.current_farm.get("resources", {})
	for key in cost.keys():
		if res.get(key, 0) < cost[key]:
			return false
	return true

func _pay_cost(cost: Dictionary) -> void:
	if cost.is_empty():
		return
	if not GameState or not GameState.current_farm:
		return
	var res: Dictionary = GameState.current_farm.get("resources", {})
	for key in cost.keys():
		res[key] = res.get(key, 0) - cost[key]
	GameState.current_farm["resources"] = res
	if farm_panel:
		farm_panel.set_resources(res)

func _is_overlapping(pos: Vector2) -> bool:
	var size := 64.0
	var half := size * 0.5
	var rect := Rect2(pos - Vector2(half, half), Vector2(size, size))
	for s in built_structures:
		if not is_instance_valid(s):
			continue
		var other := Rect2(s.position - Vector2(half, half), Vector2(size, size))
		if rect.intersects(other):
			return true
	return false

func _finalize_build(def: Dictionary, pos: Vector2) -> void:
	if not _can_afford(def.get("cost", {})):
		print("Not enough resources to build %s" % def.get("display_name", def.get("id", "")))
		return
	var def_copy := def.duplicate()
	def_copy["position"] = pos
	building_defs.append(def_copy)
	var building = create_building(def_copy.get("display_name", "Structure"), pos)
	building.set_meta("id", def_copy.get("id", ""))
	building.set_meta("job_type_id", def_copy.get("job_type_id", ""))
	buildings.add_child(building)
	built_structures.append(building)
	_pay_cost(def_copy.get("cost", {}))
	if farm_manager:
		farm_manager.structures.append(building)
		var job_type_id: String = def_copy.get("job_type_id", "")
		if not job_type_id.is_empty():
			farm_manager.post_job(job_type_id, building.global_position, {"structure_id": def_copy.get("id", ""), "built_via_ui": true})
	_refresh_farm_ui()

func _resolve_building_definition(entry) -> Dictionary:
	var def: Dictionary = {}
	var entry_id := ""
	if typeof(entry) == TYPE_DICTIONARY:
		entry_id = entry.get("id", "")
		def = entry.duplicate()
	elif typeof(entry) == TYPE_STRING:
		entry_id = entry
		def = {"id": entry_id}

	if entry_id.is_empty():
		return {}

	var res_path := "res://data/buildings/%s.tres" % entry_id
	var res := load(res_path)
	if res:
		def["display_name"] = res.get("display_name", def.get("display_name", entry_id.capitalize()))
		def["job_type_id"] = res.get("job_type_id", def.get("job_type_id", "job_build"))
		def["position"] = def.get("position", res.get("default_position", Vector2(100 + building_defs.size() * 80, 100)))
		def["placement_type"] = res.get("placement_type", "structure")
		def["snap_step"] = res.get("snap_step", Vector2(40, 0))
		def["cost"] = res.get("cost", {})
	else:
		def["display_name"] = def.get("display_name", entry_id.capitalize())
		def["job_type_id"] = def.get("job_type_id", "job_build")
		def["position"] = def.get("position", Vector2(100 + building_defs.size() * 80, 100))
		def["placement_type"] = def.get("placement_type", "structure")
		def["snap_step"] = def.get("snap_step", Vector2(40, 0))
		def["cost"] = def.get("cost", {})

	return def
