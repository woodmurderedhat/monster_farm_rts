extends Node2D
## Zone scene controller

@export var farm_scene_path: String = "res://scenes/farm_scene.tscn"

@onready var zone_label = $ZoneEnvironment/ZoneLabel
@onready var enemy_team = $EnemyTeam
@onready var player_team = $PlayerTeam

@export var zone_id: String = "zone_grassland"

var zone_manager: ZoneManager
var combat_manager: CombatManager
var assembler: MonsterAssembler
var current_zone_data: Resource
var respawn_timer: Timer
var respawn_interval: float = 5.0
var zone_cleared_emitted: bool = false
var rewards_granted: bool = false
var respawn_cycle: int = 0

func _ready():
	GameState.change_state(GameState.State.WORLD_EXPLORATION)
	_assign_systems()
	load_zone(zone_id)
	spawn_initial_monsters()
	_setup_respawn_timer()

func _assign_systems():
	zone_manager = get_node_or_null("/root/GameWorld/ZoneManager")
	combat_manager = get_node_or_null("/root/GameWorld/CombatManager")
	assembler = get_node_or_null("/root/GameWorld/MonsterAssembler")

	if not assembler:
		assembler = MonsterAssembler.new()

func load_zone(id: String):
	var zone_path = "res://data/zones/%s.tres" % id
	current_zone_data = load(zone_path)

	if current_zone_data:
		zone_label.text = String(current_zone_data.display_name) if current_zone_data.has("display_name") else zone_id
		if current_zone_data.has("spawn_rate"):
			respawn_interval = float(current_zone_data.spawn_rate)
		if zone_manager and zone_manager.has_method("enter_zone"):
			zone_manager.enter_zone(id)
		if GameState:
			GameState.current_zone = id
	else:
		print("Failed to load zone: %s" % id)

func spawn_initial_monsters():
	if not GameState:
		return

	var positions = [Vector2(100, 200), Vector2(150, 200), Vector2(200, 200), Vector2(250, 200)]
	for i in range(min(GameState.owned_monsters.size(), 4)):
		var dna_stack = GameState.owned_monsters[i]
		var spawned = assembler.assemble_monster(dna_stack, MonsterAssembler.SpawnContext.WORLD)
		if spawned:
			spawned.position = positions[i % positions.size()]
			spawned.set_meta("team", 0)
			player_team.add_child(spawned)
			if combat_manager:
				combat_manager.register_combatant(spawned)

		spawn_enemy_wave()

func _process(_delta):
	if enemy_team.get_child_count() == 0:
		if not zone_cleared_emitted:
			complete_zone()
		if respawn_timer and not respawn_timer.is_stopped():
			return
		if respawn_timer:
			respawn_timer.start(respawn_interval)

func complete_zone():
	EventBus.zone_cleared.emit(zone_id)
	zone_cleared_emitted = true
	if GameState and not rewards_granted:
		GameState.player_state["gold"] += 100
		GameState.player_state["total_xp"] += 50
		rewards_granted = true

func spawn_enemy_wave():
	if not (current_zone_data and current_zone_data.has("monster_pool")):
		return
	respawn_cycle += 1
	var enemy_positions: Array[Vector2] = [Vector2(600, 200), Vector2(650, 200), Vector2(700, 200), Vector2(750, 200), Vector2(800, 200)]
	var difficulty: int = int(current_zone_data.difficulty_level) if current_zone_data.has("difficulty_level") else 1
	var count: int = int(clamp(int(2 + difficulty + respawn_cycle * 0.5), 2, enemy_positions.size()))
	for i in range(count):
		var pool: Array = current_zone_data.monster_pool if current_zone_data.has("monster_pool") else []
		if pool.is_empty():
			continue
		var enemy_core: String = pool[(i + respawn_cycle) % pool.size()]
		var spawn_stack: MonsterDNAStack = MonsterDNAStack.new()
		spawn_stack.core = load("res://data/dna/cores/%s.tres" % enemy_core)

		var assembled = assembler.assemble_monster(spawn_stack, MonsterAssembler.SpawnContext.WORLD)
		if assembled:
			assembled.position = enemy_positions[i % enemy_positions.size()]
			assembled.set_meta("team", 1)
			enemy_team.add_child(assembled)
			if combat_manager:
				combat_manager.register_combatant(assembled)

func _setup_respawn_timer():
	respawn_timer = Timer.new()
	respawn_timer.one_shot = true
	respawn_timer.stop()
	add_child(respawn_timer)
	respawn_timer.timeout.connect(_on_respawn_timeout)

func _on_respawn_timeout():
	spawn_enemy_wave()

func return_to_farm():
	GameState.change_state(GameState.State.FARM_SIMULATION)
	if get_tree():
		get_tree().change_scene_to_file(farm_scene_path)
