extends Node2D
## Raid scene - boss encounters with multiple waves

@onready var player_team = $PlayerTeam
@onready var enemy_team = $EnemyTeam
@onready var boss_health_bar = $BossHealthBar
@onready var wave_label = $WaveLabel
@onready var raid_timer = $RaidTimer
@onready var combat_manager = $CombatManager

@export var raid_id: String = "raid_goblin_incursion"

var current_raid_data = {}
var current_wave = 0
var total_waves = 1
var enemies_spawned = []
var player_monsters = []

func _ready():
	load_raid(raid_id)
	setup_teams()
	start_next_wave()
	raid_timer.timeout.connect(_on_raid_timer)
	raid_timer.start(1.0)

func load_raid(id: String):
	var raid_path = "res://data/raids/%s.tres" % id
	current_raid_data = load(raid_path)
	if current_raid_data:
		total_waves = current_raid_data.wave_count
	else:
		print("Failed to load raid: %s" % id)

func setup_teams():
	# Get assembler
	var assembler = get_node_or_null("/root/GameWorld/MonsterAssembler")
	if not assembler:
		assembler = MonsterAssembler.new()
	
	# Load player team
	if GameState and GameState.owned_monsters.size() > 0:
		var positions = [Vector2(150, 300), Vector2(200, 300), Vector2(250, 300), Vector2(300, 300)]
		for i in range(min(GameState.owned_monsters.size(), 4)):
			var monster = GameState.owned_monsters[i]
			var spawned = assembler.assemble_monster(monster)
			if spawned:
				spawned.position = positions[i]
				player_team.add_child(spawned)
				player_monsters.append(spawned)

func start_next_wave():
	current_wave += 1
	wave_label.text = "Wave %d / %d" % [current_wave, total_waves]
	
	if current_wave > total_waves:
		complete_raid()
		return
	
	# Get assembler
	var assembler = get_node_or_null("/root/GameWorld/MonsterAssembler")
	if not assembler:
		assembler = MonsterAssembler.new()
	
	# Spawn enemy wave
	if current_raid_data and current_raid_data.enemy_pool:
		var enemy_positions = [Vector2(650, 250), Vector2(700, 250), Vector2(750, 250), Vector2(800, 250)]
		for i in range(min(current_raid_data.enemy_pool.size(), 4)):
			var enemy_id = current_raid_data.enemy_pool[i]
			var spawn_stack = MonsterDNAStack.new()
			spawn_stack.core = load("res://data/dna/cores/%s.tres" % enemy_id)
			
			var spawned = assembler.assemble_monster(spawn_stack)
			if spawned:
				spawned.position = enemy_positions[i]
				enemy_team.add_child(spawned)
				enemies_spawned.append(spawned)

func _on_raid_timer():
	# Check for wave completion
	var alive_enemies = enemy_team.get_child_count()
	if alive_enemies == 0 and current_wave < total_waves:
		start_next_wave()

func complete_raid():
	print("Raid completed!")
	EventBus.raid_completed.emit(raid_id)
	GameState.player_state["gold"] += current_raid_data.reward_gold
	GameState.player_state["total_xp"] += current_raid_data.reward_xp
	EventBus.game_state_changed.emit(GameState.get_state_dict())
	
	# Return to farm or world
	get_tree().change_scene_to_file("res://scenes/farm_scene.tscn")
