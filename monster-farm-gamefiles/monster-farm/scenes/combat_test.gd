# Combat Test Scene - 2v2 Battle
# Tests combat system with predefined monster teams
extends Node2D

@onready var monster_assembler := MonsterAssembler.new()
@onready var combat_manager := CombatManager.new()

# Preload monster presets
const SPRIGKIN_PRESET := preload("res://data/monsters/preset_sprigkin_fire.tres")
const BARKMAW_PRESET := preload("res://data/monsters/preset_barkmaw_tank.tres")
const SPORESPAWN_PRESET := preload("res://data/monsters/preset_sporespawn_support.tres")
const SERPENT_PRESET := preload("res://data/monsters/preset_serpent_assassin.tres")

# Team spawn positions
const TEAM_0_POS := Vector2(200, 300)
const TEAM_1_POS := Vector2(600, 300)
const SPAWN_SPACING := 100.0

var monsters: Array[Node2D] = []


func _ready() -> void:
	add_child(monster_assembler)
	add_child(combat_manager)
	
	print("\n=== COMBAT TEST 2v2 ===")
	print("Spawning teams...")
	
	# Spawn Team 0 (Player)
	_spawn_team(0, TEAM_0_POS, [SPRIGKIN_PRESET, BARKMAW_PRESET])
	
	# Spawn Team 1 (Enemy)
	_spawn_team(1, TEAM_1_POS, [SERPENT_PRESET, SPORESPAWN_PRESET])
	
	print("Teams spawned. Combat will begin automatically.")
	print("Team 0 (Player): %d monsters" % _get_team_count(0))
	print("Team 1 (Enemy): %d monsters" % _get_team_count(1))
	
	# Start combat after 1 second
	await get_tree().create_timer(1.0).timeout
	_start_combat()


func _spawn_team(team: int, base_pos: Vector2, presets: Array) -> void:
	for i in range(presets.size()):
		var preset: MonsterDNAStack = presets[i]
		var monster := monster_assembler.assemble_monster(preset, MonsterAssembler.SpawnContext.WORLD)
		
		if monster:
			monster.global_position = base_pos + Vector2(0, i * SPAWN_SPACING)
			monster.set_meta("team", team)
			monster.name = "%s_Team%d" % [preset.core.display_name if preset.core else "Monster", team]
			
			add_child(monster)
			monsters.append(monster)
			combat_manager.register_combatant(monster)
			
			print("  Spawned: %s at %v" % [monster.name, monster.global_position])


func _start_combat() -> void:
	print("\n=== COMBAT STARTED ===")
	
	# Give all monsters on team 0 a target from team 1
	var team_1_monsters := _get_team_monsters(1)
	if not team_1_monsters.is_empty():
		var first_enemy := team_1_monsters[0]
		
		for monster in _get_team_monsters(0):
			var combat_ai := monster.get_node_or_null("CombatAIComponent")
			if combat_ai:
				combat_ai.current_target = first_enemy
				combat_ai.combat_state = combat_ai.CombatState.ENGAGE
	
	# Give all monsters on team 1 a target from team 0
	var team_0_monsters := _get_team_monsters(0)
	if not team_0_monsters.is_empty():
		var first_player := team_0_monsters[0]
		
		for monster in _get_team_monsters(1):
			var combat_ai := monster.get_node_or_null("CombatAIComponent")
			if combat_ai:
				combat_ai.current_target = first_player
				combat_ai.combat_state = combat_ai.CombatState.ENGAGE
	
	print("Targets assigned. Combat AI engaged.")


func _get_team_monsters(team: int) -> Array[Node2D]:
	var result: Array[Node2D] = []
	for monster in monsters:
		if is_instance_valid(monster) and monster.get_meta("team", -1) == team:
			result.append(monster)
	return result


func _get_team_count(team: int) -> int:
	return _get_team_monsters(team).size()


func _process(_delta: float) -> void:
	# Check for combat end
	var team_0_alive := _get_team_count(0)
	var team_1_alive := _get_team_count(1)
	
	if team_0_alive == 0 and team_1_alive == 0:
		print("\n=== COMBAT ENDED: Draw (all dead) ===")
		set_process(false)
	elif team_0_alive == 0:
		print("\n=== COMBAT ENDED: Team 1 Victory ===")
		set_process(false)
	elif team_1_alive == 0:
		print("\n=== COMBAT ENDED: Team 0 Victory ===")
		set_process(false)
