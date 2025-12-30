extends Node2D
## Zone scene controller

@onready var zone_manager = $ZoneManager
@onready var monster_spawner = $MonsterSpawner
@onready var enemy_team = $EnemyTeam
@onready var player_team = $PlayerTeam
@onready var zone_label = $ZoneEnvironment/ZoneLabel

@export var zone_id: String = "zone_grassland"

var current_zone_data = {}

func _ready():
	load_zone(zone_id)
	spawn_initial_monsters()

func load_zone(id: String):
	# Load zone resource
	var zone_path = "res://data/zones/%s.tres" % id
	current_zone_data = load(zone_path)
	
	if current_zone_data:
		zone_label.text = current_zone_data.display_name
		zone_manager.setup_zone(current_zone_data)
	else:
		print("Failed to load zone: %s" % id)

func spawn_initial_monsters():
	# Get assembler from the scene tree
	var assembler = get_node_or_null("/root/GameWorld/MonsterAssembler")
	if not assembler:
		print("Warning: MonsterAssembler not found, creating temp instance")
		assembler = MonsterAssembler.new()
	
	# Spawn player team first
	if GameState and GameState.owned_monsters.size() > 0:
		var positions = [Vector2(100, 200), Vector2(150, 200), Vector2(200, 200), Vector2(250, 200)]
		for i in range(min(GameState.owned_monsters.size(), 4)):
			var monster = GameState.owned_monsters[i]
			var spawned = assembler.assemble_monster(monster)
			if spawned:
				spawned.position = positions[i]
				player_team.add_child(spawned)
	
	# Spawn enemy team
	if current_zone_data and current_zone_data.monster_pool:
		var enemy_positions = [Vector2(600, 200), Vector2(650, 200), Vector2(700, 200)]
		for i in range(min(current_zone_data.monster_pool.size(), 3)):
			var enemy_core = current_zone_data.monster_pool[i]
			var spawn_stack = MonsterDNAStack.new()
			spawn_stack.core = load("res://data/dna/cores/%s.tres" % enemy_core)
			
			var assembled = assembler.assemble_monster(spawn_stack)
			if assembled:
				assembled.position = enemy_positions[i]
				enemy_team.add_child(assembled)

func _process(_delta):
	# Check for zone completion
	if enemy_team.get_child_count() == 0:
		complete_zone()

func complete_zone():
	EventBus.zone_cleared.emit(zone_id)
	# Reward player
	GameState.player_state["gold"] += 100
	GameState.player_state["total_xp"] += 50
	EventBus.game_state_changed.emit(GameState.get_state_dict())
