# Game World - Main game scene controller
# Manages the world, monsters, and player interaction
extends Node2D
class_name GameWorld

# Preload system classes (no const to avoid shadowing global classes)
var ZoneManagerScript = preload("res://systems/world/zone_manager.gd")
var WorldEventManagerScript = preload("res://systems/world/world_event_manager.gd")
var NarrativeEventManagerScript = preload("res://core/events/narrative_event_manager.gd")
var AutomationSchedulerScript = preload("res://systems/automation/automation_scheduler.gd")
var ProgressionManagerScript = preload("res://systems/progression/progression_manager.gd")
var GameStateManagerScript = preload("res://core/globals/game_state_manager.gd")
var PlayerScene = preload("res://entities/player/player.tscn")

# Dev toggle: set in Inspector to enable spawning test monsters in play builds
@export var spawn_test_monsters: bool = false
@export var test_monster_set: MonsterTestSet = preload("res://data/monsters/test_monsters.tres")

## Core Systems
var monster_assembler: MonsterAssembler
var combat_manager: CombatManager
var selection_manager: SelectionManager
var command_manager: CommandManager

## World Systems
var zone_manager  # ZoneManager
var world_event_manager  # WorldEventManager
var narrative_manager  # NarrativeEventManager

## Farm Systems
var farm_manager: FarmManager
var automation_scheduler  # AutomationScheduler

## Progression Systems
var progression_manager  # ProgressionManager

## Raid System
var raid_manager: RaidManager

## Game State
var game_state_manager  # GameStateManager

## Player
var player  # Player (Node)

## Container for spawned monsters
@onready var monsters_container: Node2D = $Monsters

## Reference to the camera
@onready var camera: Camera2D = $Camera2D

## UI layer
var main_ui: CanvasLayer
var pause_menu: CanvasLayer


func _ready() -> void:
	_setup_systems()
	_setup_ui()
	_connect_signals()
	
	# Only spawn developer test monsters when explicitly enabled or in editor
	if spawn_test_monsters or Engine.is_editor_hint():
		_spawn_test_monsters()


## Setup game systems
func _setup_systems() -> void:
	# === Core Combat Systems ===
	# Create monster assembler
	monster_assembler = MonsterAssembler.new()
	add_child(monster_assembler)
	
	# Create combat manager
	combat_manager = CombatManager.new()
	add_child(combat_manager)
	
	# Create selection manager
	selection_manager = SelectionManager.new()
	add_child(selection_manager)
	
	# Create command manager
	command_manager = CommandManager.new()
	command_manager.selection_manager = selection_manager
	command_manager.combat_manager = combat_manager
	add_child(command_manager)
	
	# === World Systems ===
	# Zone Manager
	zone_manager = ZoneManager.new()
	zone_manager.name = "ZoneManager"
	add_child(zone_manager)
	
	# World Event Manager
	world_event_manager = WorldEventManager.new()
	world_event_manager.name = "WorldEventManager"
	add_child(world_event_manager)
	
	# Narrative Event Manager
	narrative_manager = NarrativeEventManager.new()
	narrative_manager.name = "NarrativeEventManager"
	add_child(narrative_manager)
	
	# === Farm Systems ===
	# Farm Manager
	farm_manager = FarmManager.new()
	farm_manager.name = "FarmManager"
	add_child(farm_manager)
	
	# Automation Scheduler
	automation_scheduler = AutomationScheduler.new()
	automation_scheduler.name = "AutomationScheduler"
	farm_manager.add_child(automation_scheduler)
	
	# === Progression System ===
	progression_manager = ProgressionManager.new()
	progression_manager.name = "ProgressionManager"
	add_child(progression_manager)
	
	# === Raid System ===
	raid_manager = RaidManager.new()
	raid_manager.name = "RaidManager"
	raid_manager.monster_assembler = monster_assembler
	raid_manager.combat_manager = combat_manager
	raid_manager.farm_manager = farm_manager
	add_child(raid_manager)
	
	# === Game State Manager ===
	game_state_manager = GameStateManager.new()
	game_state_manager.name = "GameStateManager"
	add_child(game_state_manager)
	
	# Register managers with game state manager
	game_state_manager.register_manager("combat", combat_manager)
	game_state_manager.register_manager("farm", farm_manager)
	game_state_manager.register_manager("world_event", world_event_manager)
	game_state_manager.register_manager("raid", raid_manager)
	game_state_manager.register_manager("zone", zone_manager)
	
	# === Player ===
	_spawn_player()
	
	# Set initial game state
	game_state_manager.change_state(GameStateManager.GameMode.WORLD_EXPLORATION)


## Setup UI systems
func _setup_ui() -> void:
	# Load main UI
	var main_ui_scene = load("res://scenes/main_ui.tscn")
	if main_ui_scene:
		main_ui = main_ui_scene.instantiate()
		add_child(main_ui)
	
	# Load pause menu
	var pause_scene = load("res://scenes/pause_menu.tscn")
	if pause_scene:
		pause_menu = pause_scene.instantiate()
		add_child(pause_menu)


## Connect important signals
func _connect_signals() -> void:
	if EventBus:
		EventBus.monster_spawned.connect(_on_monster_spawned)
		EventBus.damage_dealt.connect(_on_damage_dealt)
		EventBus.zone_cleared.connect(_on_zone_cleared)
		EventBus.raid_started.connect(_on_raid_started)
		EventBus.raid_ended.connect(_on_raid_ended)


func _on_monster_spawned(monster):
	combat_manager.register_combatant(monster)

func _on_damage_dealt(attacker, _target, damage):
	if main_ui:
		main_ui.add_log_entry("%s dealt %d damage!" % [attacker.name, damage])

func _on_zone_cleared(zone_id):
	if main_ui:
		main_ui.add_log_entry("Zone cleared: %s" % zone_id)

func _on_raid_started(_raid_data):
	print("Raid started!")


func _on_raid_ended(success: bool):
	if main_ui:
		main_ui.add_log_entry("Raid %s" % ("defended" if success else "failed"))


## Spawn test monsters for development
func _spawn_test_monsters() -> void:
	var test_set: MonsterTestSet = test_monster_set
	if not test_set:
		test_set = load("res://data/monsters/test_monsters.tres") as MonsterTestSet
	
	if not test_set:
		push_warning("No test monster set provided; falling back to default presets")
		_spawn_legacy_test_monsters()
		return

	print("\n=== Spawning Test Monsters ===")
	_spawn_test_team(test_set.team0, test_set.team0_positions, 0, "Player")
	_spawn_test_team(test_set.team1, test_set.team1_positions, 1, "Enemy")
	print("=== Test Monsters Ready ===\n")


func _spawn_test_team(dna_stacks: Array[MonsterDNAStack], positions: Array[Vector2], team: int, name_prefix: String) -> void:
	for index in dna_stacks.size():
		var dna_stack: MonsterDNAStack = dna_stacks[index]
		if not dna_stack:
			push_warning("Empty DNA stack in test_monsters set for team %d at slot %d" % [team, index])
			continue

		var monster: Node2D = monster_assembler.assemble_monster(dna_stack, MonsterAssembler.SpawnContext.WORLD)
		if not monster:
			push_warning("Failed to assemble test monster for team %d at slot %d" % [team, index])
			continue

		var spawn_position: Vector2
		if positions.size() > index:
			spawn_position = positions[index]
		else:
			spawn_position = _get_default_test_spawn(team, index)

		monster.global_position = spawn_position
		monster.set_meta("team", team)
		monster.name = "%s_%d" % [name_prefix, index]
		monsters_container.add_child(monster)
		combat_manager.register_combatant(monster)
		EventBus.monster_spawned.emit(monster)
		print("  Spawned: %s (Team %d)" % [monster.name, team])


func _get_default_test_spawn(team: int, index: int) -> Vector2:
	var base_x := 150.0 if team == 0 else 500.0
	return Vector2(base_x, 200.0 + 100.0 * float(index))


func _spawn_legacy_test_monsters() -> void:
	var sprigkin_preset := load("res://data/monsters/preset_sprigkin_fire.tres") as MonsterDNAStack
	var barkmaw_preset := load("res://data/monsters/preset_barkmaw_tank.tres") as MonsterDNAStack
	var serpent_preset := load("res://data/monsters/preset_serpent_assassin.tres") as MonsterDNAStack
	var sporespawn_preset := load("res://data/monsters/preset_sporespawn_support.tres") as MonsterDNAStack
	
	if not sprigkin_preset:
		push_warning("Could not load monster presets")
		return
	
	print("\n=== Spawning Legacy Test Monsters ===")
	
	var legacy_team0 := [sprigkin_preset, barkmaw_preset]
	var legacy_team1 := [serpent_preset, sporespawn_preset]
	
	_spawn_test_team(legacy_team0, [Vector2(150, 200), Vector2(150, 300)], 0, "Player")
	_spawn_test_team(legacy_team1, [Vector2(500, 200), Vector2(500, 300)], 1, "Enemy")
	
	print("=== Legacy Test Monsters Ready ===\n")


## Spawn a monster from a DNA stack
func spawn_monster(dna_stack: MonsterDNAStack, spawn_position: Vector2, team: int = 0) -> Node2D:
	var monster := monster_assembler.assemble_monster(dna_stack, MonsterAssembler.SpawnContext.WORLD)
	if monster:
		monster.global_position = spawn_position
		monster.set_meta("team", team)
		monsters_container.add_child(monster)
		combat_manager.register_combatant(monster)
		EventBus.monster_spawned.emit(monster)
	return monster

## Spawn the player character
func _spawn_player() -> void:
	if PlayerScene:
		player = PlayerScene.instantiate()
		player.name = "Player"
		player.global_position = Vector2(200, 300)
		add_child(player)
	else:
		push_warning("Player scene not found")

## Enter farm mode
func enter_farm_mode() -> void:
	if game_state_manager:
		game_state_manager.enter_farm()

## Enter world exploration mode
func enter_world_mode() -> void:
	if game_state_manager:
		game_state_manager.enter_world()

## Start a raid
func start_raid(raid_data: Dictionary = {}) -> void:
	if game_state_manager:
		game_state_manager.start_raid()
	
	if raid_manager:
		# Raid manager will handle the actual raid logic
		EventBus.raid_started.emit(raid_data)

## Get all monsters on a specific team
func get_monsters_by_team(team: int) -> Array[Node]:
	var result: Array[Node] = []
	for child in monsters_container.get_children():
		if child.has_meta("team") and child.get_meta("team") == team:
			result.append(child)
	return result
