extends Node

# SaveManager - JSON save/load manager following Save/Load spec
# Writes to `user://save_slot_X/` with files: meta.json, world_state.json,
# farm_state.json, player_state.json, mod_state.json

const SAVE_VERSION := "0.1.0"
const SAVE_FOLDER_PREFIX := "save_slot_"

func _ready() -> void:
	print("[DEBUG] SaveManager initialized.")

func _get_slot_path(slot: int) -> String:
	return "%s%s%d/" % ["user://", SAVE_FOLDER_PREFIX, slot]

func save_slot(slot: int = 0) -> bool:
	var base_path := _get_slot_path(slot)
	# Ensure folder exists
	var dir = DirAccess.open("user://")
	if not dir:
		push_error("Unable to open user://"); return false
	var folder_name := SAVE_FOLDER_PREFIX + str(slot)
	if not dir.dir_exists(folder_name):
		var err = dir.make_dir(folder_name)
		if err != OK:
			push_error("Failed to create save folder: %s" % folder_name)
			return false

	# Meta
	var meta := {
		"save_version": SAVE_VERSION,
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"timestamp": Time.get_unix_time_from_system(),
		"mods_enabled": [],
		"playtime": 0
	}
	# Try to populate mods_enabled from a ModLoader autoload if present
	var mod_loader := get_node_or_null("/root/ModLoader")
	if mod_loader:
		if mod_loader.has_method("get_enabled_mods"):
			meta["mods_enabled"] = mod_loader.call("get_enabled_mods")
		elif mod_loader.has("enabled_mods"):
			meta["mods_enabled"] = mod_loader.enabled_mods
	# Try to compute playtime from GameState if available
	var gs_play := get_node_or_null("/root/GameState")
	if gs_play:
		if gs_play.has("playtime"):
			meta["playtime"] = gs_play.playtime
		elif gs_play.has("session_start_time"):
			meta["playtime"] = int(Time.get_unix_time_from_system() - gs_play.session_start_time)
	if not _write_json(base_path + "meta.json", meta):
		return false

	# World state - attempt to query WorldManager for canonical world data
	var world_state := {"regions": [], "global_flags": {}}
	var world_mgr := get_node_or_null("/root/WorldManager")
	if world_mgr:
		if world_mgr.has_method("get_world_state"):
			world_state = world_mgr.call("get_world_state")
		elif world_mgr.has_method("get_state"):
			world_state = world_mgr.call("get_state")
	if not _write_json(base_path + "world_state.json", world_state):
		return false

	# Farm state - try to pull from autoload `GameState` if available
	var farm_state := {}
	var gs = get_node_or_null("/root/GameState")
	if gs:
		if gs.has("current_farm"):
			farm_state = gs.current_farm
		else:
			farm_state = {}
	else:
		farm_state = {}
	if not _write_json(base_path + "farm_state.json", farm_state):
		return false

	# Player state - store owned monsters and dna collection if present
	var player_state := {}
	var gs2 = get_node_or_null("/root/GameState")
	if gs2:
		var owned = []
		if typeof(gs2.owned_monsters) == TYPE_ARRAY:
			for m in gs2.owned_monsters:
				owned.append(_serialize_any(m))
		var dna = []
		if typeof(gs2.dna_collection) == TYPE_ARRAY:
			for d in gs2.dna_collection:
				dna.append(_serialize_any(d))
		player_state = {"owned_monsters": owned, "dna_collection": dna}
		# Optional player profile fields from GameState
		if gs2.has("unlocked_biomes"):
			player_state["unlocked_biomes"] = gs2.unlocked_biomes
		if gs2.has("known_dna"):
			player_state["known_dna"] = gs2.known_dna
		if gs2.has("research_progress"):
			player_state["research_progress"] = gs2.research_progress
	else:
		player_state = {}
	if not _write_json(base_path + "player_state.json", player_state):
		return false

	# Mod state - ask ModLoader for per-mod state if available
	var mod_state := {}
	if mod_loader and mod_loader.has_method("get_mod_state"):
		mod_state = mod_loader.call("get_mod_state")
	if not _write_json(base_path + "mod_state.json", mod_state):
		return false

	# Emit event if EventBus autoload is present
	var eb = get_node_or_null("/root/EventBus")
	if eb and eb.has_signal("game_saved"):
		eb.emit_signal("game_saved")

	return true

func load_slot(slot: int = 0) -> bool:
	var base_path := _get_slot_path(slot)
	var meta = _read_json(base_path + "meta.json")
	if meta == null:
		push_error("Save meta not found for slot %d" % slot)
		return false
	# Check save version compatibility
	if meta.has("save_version") and meta["save_version"] != SAVE_VERSION:
		push_warning("Save version mismatch: %s != %s. Attempting best-effort load." % [meta["save_version"], SAVE_VERSION])

	var world_state = _read_json(base_path + "world_state.json")
	var farm_state = _read_json(base_path + "farm_state.json")
	var player_state = _read_json(base_path + "player_state.json")
	var mod_state = _read_json(base_path + "mod_state.json")

	# Restore minimal pieces into GameState if available
	var gs = get_node_or_null("/root/GameState")
	if gs and farm_state != null:
		gs.current_farm = farm_state
		if player_state != null:
			gs.owned_monsters = []
			if player_state.has("owned_monsters"):
				for mdata in player_state["owned_monsters"]:
					var res = _try_load_resource(mdata)
					if res != null:
						gs.owned_monsters.append(res)
					else:
						push_warning("Failed to restore owned_monster resource, keeping raw data")
						gs.owned_monsters.append(mdata)
			gs.dna_collection = []
			if player_state.has("dna_collection"):
				for ddata in player_state["dna_collection"]:
					var r = _try_load_resource(ddata)
					if r != null:
						gs.dna_collection.append(r)
					else:
						push_warning("Failed to restore dna resource, keeping raw data")
						gs.dna_collection.append(ddata)
			# Restore world state if present
			if world_state != null:
				gs.world_state = world_state
		# Restore mod state if ModLoader is present
		var mod_loader := get_node_or_null("/root/ModLoader")
		if mod_loader and mod_state != null:
			if mod_loader.has_method("set_mod_state"):
				mod_loader.call("set_mod_state", mod_state)
			elif mod_loader.has("mod_state"):
				mod_loader.mod_state = mod_state

		# Forward world state into WorldManager if available
		var world_mgr := get_node_or_null("/root/WorldManager")
		if world_mgr and world_state != null:
			if world_mgr.has_method("load_world_state"):
				world_mgr.call("load_world_state", world_state)
			elif world_mgr.has_method("set_state"):
				world_mgr.call("set_state", world_state)

	# Emit event if EventBus autoload is present
	var eb = get_node_or_null("/root/EventBus")
	if eb and eb.has_signal("game_loaded"):
		eb.emit_signal("game_loaded")

	return true

func _write_json(path: String, data: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.ModeFlags.WRITE)
	if file == null:
		push_error("Failed to open file for writing: %s" % path)
		return false
	var json := JSON.stringify(data)
	file.store_string(json)
	file.close()
	return true

func _read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.ModeFlags.READ)
	if file == null:
		push_error("Failed to open file for reading: %s" % path)
		return null
	var contents := file.get_as_text()
	file.close()
	var parser := JSON.new()
	var err := parser.parse(contents)
	if err != OK:
		push_error("JSON parse error for %s (code %d)" % [path, err])
		return null
	return parser.data

func _serialize_any(x: Variant) -> Variant:
	if typeof(x) == TYPE_DICTIONARY:
		return x
	if typeof(x) == TYPE_OBJECT and x is Resource:
		var out := {}
		out["resource_class"] = x.get_class()
		out["resource_path"] = x.resource_path if x.resource_path != "" else null
		# Capture inline exported properties as a fallback
		var inline_props := {}
		for p in x.get_property_list():
			if p.has("usage") and (p.usage & PROPERTY_USAGE_STORAGE) != 0:
				var prop_name: String = p.name
				inline_props[prop_name] = x.get(prop_name)
		if inline_props.size() > 0:
			out["inline_properties"] = inline_props
		return out
	return x

func _try_load_resource(data: Variant) -> Resource:
	if typeof(data) != TYPE_DICTIONARY:
		return null
	if data.has("resource_path") and data["resource_path"] != null:
		var p: String = data["resource_path"]
		var loaded := ResourceLoader.load(p)
		if loaded == null:
			push_warning("Failed to load resource at %s" % str(p))
		return loaded
	# No path provided; attempt best-effort restore from inline properties
	if data.has("inline_properties") and data.has("resource_class"):
		push_warning("Inline resource data present for %s — runtime reconstruction not supported yet" % data["resource_class"])
	return null
