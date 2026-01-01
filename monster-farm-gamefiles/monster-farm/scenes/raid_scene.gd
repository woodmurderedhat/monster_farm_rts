extends Node2D
## Raid scene - boss encounters with multiple waves

@onready var player_team = $PlayerTeam
@onready var enemy_team = $EnemyTeam
@onready var boss_health_bar = $BossHealthBar
@onready var wave_label = $WaveLabel
@onready var raid_timer = $RaidTimer
@onready var combat_manager = $CombatManager

@export var raid_id: String = "raid_goblin_incursion"

var current_raid_data: RaidResource
var current_wave: int = 0
var total_waves: int = 1
var enemies_spawned: Array[Node] = []
var player_monsters: Array[Node] = []

var assembler: MonsterAssembler
var raid_manager: RaidManager
var raid_over: bool = false
var boss_target: Node = null
var boss_name_label: Label
var boss_portrait: TextureRect
var boss_portrait_texture: Texture2D
var boss_display_name: String = ""

func _ready():
	GameState.change_state(GameState.State.RAID_DEFENSE)
	_assign_systems()
	load_raid(raid_id)
	setup_teams()
	start_next_wave()
	raid_timer.timeout.connect(_on_raid_timer)
	raid_timer.start(1.0)
	_update_hud()
	boss_name_label = get_node_or_null("BossName") as Label
	boss_portrait = get_node_or_null("BossPortrait") as TextureRect

func _assign_systems():
	raid_manager = get_node_or_null("/root/GameWorld/RaidManager")
	assembler = get_node_or_null("/root/GameWorld/MonsterAssembler")
	if not assembler:
		assembler = MonsterAssembler.new()

func load_raid(id: String):
	var raid_path = "res://data/raids/%s.tres" % id
	var raid_res: Resource = load(raid_path)
	if raid_res and raid_res is RaidResource:
		current_raid_data = raid_res
		total_waves = current_raid_data.wave_count
		boss_display_name = String(current_raid_data.boss_name) if current_raid_data.has("boss_name") else ""
		var portrait_res: Texture2D = current_raid_data.boss_portrait if current_raid_data.has("boss_portrait") else null
		if portrait_res:
			boss_portrait_texture = portrait_res
		EventBus.raid_started.emit(current_raid_data)
	else:
		current_raid_data = null
		print("Failed to load raid: %s" % id)

func setup_teams():
	if GameState and GameState.owned_monsters.size() > 0:
		var positions = [Vector2(150, 300), Vector2(200, 300), Vector2(250, 300), Vector2(300, 300)]
		for i in range(min(GameState.owned_monsters.size(), 4)):
			var dna_stack = GameState.owned_monsters[i]
			var spawned = assembler.assemble_monster(dna_stack, MonsterAssembler.SpawnContext.RAID)
			if spawned:
				spawned.position = positions[i]
				spawned.set_meta("team", 0)
				player_team.add_child(spawned)
				player_monsters.append(spawned)
				if combat_manager:
					combat_manager.register_combatant(spawned)
	_update_hud()

func start_next_wave():
	current_wave += 1
	wave_label.text = "Wave %d / %d" % [current_wave, total_waves]

	if current_wave > total_waves:
		complete_raid(true)
		return

	if current_raid_data and current_raid_data.enemy_pool:
		var enemy_positions = [Vector2(650, 250), Vector2(700, 250), Vector2(750, 250), Vector2(800, 250)]
		for i in range(min(current_raid_data.enemy_pool.size(), 4)):
			var enemy_id: String = current_raid_data.enemy_pool[i]
			var spawn_stack: MonsterDNAStack = MonsterDNAStack.new()
			spawn_stack.core = load("res://data/dna/cores/%s.tres" % enemy_id)

			var spawned = assembler.assemble_monster(spawn_stack, MonsterAssembler.SpawnContext.RAID)
			if spawned:
				spawned.position = enemy_positions[i]
				spawned.set_meta("team", 1)
				enemy_team.add_child(spawned)
				enemies_spawned.append(spawned)
				if combat_manager:
					combat_manager.register_combatant(spawned)
				EventBus.raid_wave_spawned.emit(current_wave)

	if current_wave == total_waves:
		_spawn_boss_if_needed()

	_update_hud()

func _on_raid_timer():
	var alive_enemies = enemy_team.get_child_count()
	if alive_enemies == 0 and current_wave < total_waves:
		start_next_wave()
	elif alive_enemies == 0 and current_wave == total_waves:
		complete_raid(true)

func _process(_delta):
	if raid_over:
		return
	_clean_dead(player_team)
	_clean_dead(enemy_team)
	_update_boss_health_bar()
	if not _has_living_team(player_team):
		complete_raid(false)

func complete_raid(success: bool):
	if raid_over:
		return
	raid_over = true
	raid_timer.stop()
	if success:
		print("Raid completed!")
	else:
		print("Raid failed!")

	EventBus.raid_ended.emit(success)
	if GameState and current_raid_data:
		if success:
			GameState.player_state["gold"] += current_raid_data.reward_gold
			GameState.player_state["total_xp"] += current_raid_data.reward_xp

	GameState.change_state(GameState.State.FARM_SIMULATION)
	get_tree().change_scene_to_file("res://scenes/farm_scene.tscn")

func _has_living_team(team: Node) -> bool:
	for child in team.get_children():
		var health: HealthComponent = child.get_node_or_null("HealthComponent") as HealthComponent
		if health and health.is_alive():
			return true
	return false

func _clean_dead(team: Node) -> void:
	for child in team.get_children():
		var health: HealthComponent = child.get_node_or_null("HealthComponent") as HealthComponent
		if health and not health.is_alive():
			child.queue_free()

func _spawn_boss_if_needed():
	if boss_target:
		return
	var boss_id: String = String(current_raid_data.boss_id) if current_raid_data.has("boss_id") else ""
	if boss_id.is_empty():
		return
	var spawn_stack: MonsterDNAStack = MonsterDNAStack.new()
	spawn_stack.core = load("res://data/dna/cores/%s.tres" % boss_id)
	var behavior_id: String = String(current_raid_data.boss_behavior_id) if current_raid_data.has("boss_behavior_id") else ""
	if not behavior_id.is_empty():
		spawn_stack.behavior = load("res://data/dna/behaviors/%s.tres" % behavior_id)
	var ability_ids: Array = current_raid_data.boss_ability_ids if current_raid_data.has("boss_ability_ids") else []
	if ability_ids:
		for a in ability_ids:
			var ability_res: Resource = load("res://data/dna/abilities/%s.tres" % a)
			if ability_res:
				spawn_stack.abilities.append(ability_res)
	var boss: Node2D = assembler.assemble_monster(spawn_stack, MonsterAssembler.SpawnContext.RAID)
	if boss:
		boss.global_position = Vector2(720, 200)
		boss.set_meta("team", 1)
		enemy_team.add_child(boss)
		boss_target = boss
		enemies_spawned.append(boss)
		if combat_manager:
			combat_manager.register_combatant(boss)
		if boss_name_label:
			boss_name_label.text = boss_display_name if not boss_display_name.is_empty() else String(boss.name)
		if boss_portrait and boss_portrait_texture:
			boss_portrait.texture = boss_portrait_texture

func _update_boss_health_bar():
	if not boss_health_bar:
		return
	if not boss_target or not is_instance_valid(boss_target):
		boss_health_bar.visible = false
		if boss_name_label:
			boss_name_label.text = ""
		if boss_portrait:
			boss_portrait.texture = null
		return
	var health: HealthComponent = boss_target.get_node_or_null("HealthComponent") as HealthComponent
	if health:
		boss_health_bar.visible = true
		var max_hp: int = int(max(health.max_hp, 1))
		boss_health_bar.value = float(health.current_hp) / float(max_hp)
		if boss_name_label:
			boss_name_label.text = boss_target.name
	else:
		boss_health_bar.visible = false

func _update_hud():
	if wave_label:
		wave_label.text = "Wave %d / %d" % [max(1, current_wave), max(1, total_waves)]
	if boss_health_bar:
		var boss_id: String = String(current_raid_data.boss_id) if current_raid_data and current_raid_data.has("boss_id") else ""
		boss_health_bar.visible = not boss_id.is_empty()
