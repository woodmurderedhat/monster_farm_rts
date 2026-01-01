# Raid Manager - Handles raid events and enemy wave spawning
extends Node
class_name RaidManager

## Emitted when a raid starts
signal raid_started(raid_data: Dictionary)

## Emitted when a wave spawns
signal wave_spawned(wave_number: int, enemies: Array[Node2D])

## Emitted when a raid ends
signal raid_ended(success: bool, stats: Dictionary)

## Current raid data
var current_raid: Dictionary = {}

## Whether a raid is active
var is_raid_active: bool = false

## Current wave number
var current_wave: int = 0

## Enemies spawned this raid
var raid_enemies: Array[Node2D] = []

## Reference to monster assembler
var monster_assembler: MonsterAssembler

## Reference to combat manager
var combat_manager: CombatManager

## Reference to farm manager
var farm_manager: FarmManager

## Spawn points for enemies
var spawn_points: Array[Vector2] = []

## Timer for wave spawning
var wave_timer: float = 0.0


func _ready() -> void:
	EventBus.monster_died.connect(_on_monster_died)


func _process(delta: float) -> void:
	if is_raid_active:
		_update_raid(delta)


## Start a raid event
func start_raid(raid_data: Dictionary) -> void:
	if is_raid_active:
		push_warning("Raid already in progress")
		return
	
	current_raid = raid_data
	is_raid_active = true
	current_wave = 0
	raid_enemies.clear()
	wave_timer = 0.0
	
	EventBus.raid_started.emit(raid_data)
	raid_started.emit(raid_data)
	
	# Inject defense jobs
	_inject_defense_jobs()
	
	# Spawn first wave
	_spawn_wave()


## End the current raid
func end_raid(success: bool) -> void:
	if not is_raid_active:
		return
	
	var stats := {
		"waves_completed": current_wave,
		"enemies_killed": _count_dead_enemies(),
		"success": success
	}
	
	is_raid_active = false
	current_raid = {}
	
	# Clean up remaining enemies
	for enemy in raid_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	raid_enemies.clear()
	
	EventBus.raid_ended.emit(success)
	raid_ended.emit(success, stats)


## Update raid state
func _update_raid(delta: float) -> void:
	# Check if all enemies are dead
	var alive_count := 0
	for enemy in raid_enemies:
		if is_instance_valid(enemy):
			var health := enemy.get_node_or_null("HealthComponent") as HealthComponent
			if health and health.is_alive():
				alive_count += 1
	
	# Wave cleared
	if alive_count == 0 and current_wave > 0:
		var total_waves: int = current_raid.get("total_waves", 3)
		if current_wave >= total_waves:
			end_raid(true)
			return
		
		# Wait for next wave
		wave_timer += delta
		var wave_delay: float = current_raid.get("wave_delay", 10.0)
		if wave_timer >= wave_delay:
			wave_timer = 0.0
			_spawn_wave()


## Spawn a wave of enemies
func _spawn_wave() -> void:
	current_wave += 1
	
	var wave_data: Array = current_raid.get("waves", [])
	var wave_config: Dictionary = {}
	
	if current_wave <= wave_data.size():
		wave_config = wave_data[current_wave - 1]
	else:
		# Default wave
		wave_config = {"count": 3 + current_wave, "dna_stack": null}
	
	var count: int = wave_config.get("count", 3)
	var dna_stack: MonsterDNAStack = wave_config.get("dna_stack")
	
	var spawned: Array[Node2D] = []
	
	for i in range(count):
		var spawn_pos := _get_spawn_position(i)
		var enemy := _spawn_enemy(dna_stack, spawn_pos)
		if enemy:
			spawned.append(enemy)
			raid_enemies.append(enemy)
	
	EventBus.raid_wave_spawned.emit(current_wave)
	wave_spawned.emit(current_wave, spawned)


## Spawn a single enemy
func _spawn_enemy(dna_stack: MonsterDNAStack, position: Vector2) -> Node2D:
	if not monster_assembler:
		return null
	
	var enemy := monster_assembler.assemble_monster(dna_stack, MonsterAssembler.SpawnContext.RAID)
	if enemy:
		enemy.global_position = position
		enemy.set_meta("team", 1)  # Enemy team
		get_tree().current_scene.add_child(enemy)
		
		if combat_manager:
			combat_manager.register_combatant(enemy)
	
	return enemy


## Get spawn position for an enemy
func _get_spawn_position(index: int) -> Vector2:
	if spawn_points.is_empty():
		# Default spawn positions around the edge
		var angle := (index * TAU / 8.0) + randf() * 0.5
		var distance := 400.0 + randf() * 100.0
		var center: Vector2 = current_raid.get("target_position", Vector2(320, 240))
		return center + Vector2.from_angle(angle) * distance

	return spawn_points[index % spawn_points.size()]


## Inject defense jobs into the job board
func _inject_defense_jobs() -> void:
	if not farm_manager:
		return

	var target_pos: Vector2 = current_raid.get("target_position", Vector2(320, 240))

	# Post multiple defense jobs around the target
	for i in range(4):
		var angle := i * TAU / 4.0
		var pos := target_pos + Vector2.from_angle(angle) * 100.0
		farm_manager.post_job("defend", pos, {"raid_id": current_raid.get("id", "")})


## Count dead enemies
func _count_dead_enemies() -> int:
	var count := 0
	for enemy in raid_enemies:
		if not is_instance_valid(enemy):
			count += 1
			continue
		var health := enemy.get_node_or_null("HealthComponent") as HealthComponent
		if health and not health.is_alive():
			count += 1
	return count


## Handle monster death
func _on_monster_died(monster: Node2D) -> void:
	if not is_raid_active:
		return

	# Check if it was a defender (player monster)
	var team: int = monster.get_meta("team", 0)
	if team == 0:
		# Player monster died - check for failure
		if farm_manager:
			var stats := farm_manager.get_stats()
			if stats.monster_count <= 0:
				end_raid(false)


## Set spawn points for the raid
func set_spawn_points(points: Array[Vector2]) -> void:
	spawn_points = points


## Create a simple raid configuration
static func create_raid_config(
	waves: int = 3,
	enemies_per_wave: int = 3,
	wave_delay: float = 10.0,
	target_position: Vector2 = Vector2(320, 240)
) -> Dictionary:
	var wave_data: Array = []
	for i in range(waves):
		wave_data.append({
			"count": enemies_per_wave + i,
			"dna_stack": null  # Will use default enemy
		})

	return {
		"id": "raid_%d" % Time.get_ticks_msec(),
		"total_waves": waves,
		"wave_delay": wave_delay,
		"waves": wave_data,
		"target_position": target_position
	}
