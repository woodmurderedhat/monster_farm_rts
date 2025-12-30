## Progression Manager - handles player-level progression and unlocks
## Manages player XP, level, unlocked features, and research
extends Node
class_name ProgressionManager

signal player_level_up(new_level: int)
signal player_xp_gained(amount: int)
signal feature_unlocked(feature_id: String)
signal research_completed(research_id: String)

@export var player_level: int = 1
@export var player_xp: int = 0
@export var max_player_level: int = 50

var unlocked_features: Array[String] = []
var completed_research: Array[String] = []
var research_progress: Dictionary = {}  # research_id -> progress_float

## XP curve
const BASE_XP: int = 500
const XP_EXPONENT: float = 1.4

func _ready() -> void:
	_initialize_starting_features()

## Initialize features available from the start
func _initialize_starting_features() -> void:
	unlocked_features.append("basic_farm")
	unlocked_features.append("basic_combat")
	unlocked_features.append("dna_collection")

## Award player XP
func award_player_xp(amount: int) -> void:
	player_xp += amount
	player_xp_gained.emit(amount)
	
	_check_player_level_up()
	
	# Update GameState
	if GameState:
		GameState.player_level = player_level
		GameState.player_xp = player_xp

## Check for player level up
func _check_player_level_up() -> void:
	while player_xp >= get_xp_for_next_player_level() and player_level < max_player_level:
		_player_level_up()

## Perform player level up
func _player_level_up() -> void:
	player_level += 1
	player_xp -= get_xp_for_next_player_level()
	
	player_level_up.emit(player_level)
	EventBus.player_leveled_up.emit(player_level)
	
	# Check for level-based unlocks
	_check_level_unlocks()

## Check if any features unlock at this level
func _check_level_unlocks() -> void:
	var unlock_map = {
		2: "monster_storage_expansion",
		3: "automation_basics",
		5: "advanced_dna_splicing",
		7: "raid_defense",
		10: "zone_unlock_forest",
		15: "advanced_abilities",
		20: "zone_unlock_volcano"
	}
	
	if unlock_map.has(player_level):
		unlock_feature(unlock_map[player_level])

## Unlock a feature
func unlock_feature(feature_id: String) -> void:
	if feature_id not in unlocked_features:
		unlocked_features.append(feature_id)
		feature_unlocked.emit(feature_id)
		EventBus.feature_unlocked.emit(feature_id)

## Check if feature is unlocked
func is_feature_unlocked(feature_id: String) -> bool:
	return feature_id in unlocked_features

## Get XP required for next player level
func get_xp_for_next_player_level() -> int:
	return int(BASE_XP * pow(player_level, XP_EXPONENT))

## Start research
func start_research(research_id: String) -> bool:
	if research_id in completed_research:
		return false
	
	if not research_progress.has(research_id):
		research_progress[research_id] = 0.0
		return true
	
	return false

## Add research progress
func add_research_progress(research_id: String, progress: float) -> void:
	if research_id not in research_progress:
		return
	
	research_progress[research_id] += progress
	
	# Check for completion
	if research_progress[research_id] >= 100.0:
		_complete_research(research_id)

## Complete research
func _complete_research(research_id: String) -> void:
	if research_id not in completed_research:
		completed_research.append(research_id)
	
	research_progress.erase(research_id)
	research_completed.emit(research_id)
	EventBus.research_completed.emit(research_id)
	
	# Apply research benefits
	_apply_research_benefits(research_id)

## Apply benefits from completed research
func _apply_research_benefits(research_id: String) -> void:
	# This would unlock new DNA types, abilities, buildings, etc.
	match research_id:
		"advanced_genetics":
			unlock_feature("mutation_splicing")
		"farm_efficiency":
			unlock_feature("auto_feeding")
		"combat_tactics":
			unlock_feature("formation_control")

## Get research progress percentage
func get_research_progress(research_id: String) -> float:
	return research_progress.get(research_id, 0.0)

## Check if research is completed
func is_research_completed(research_id: String) -> bool:
	return research_id in completed_research

## Serialize for save system
func serialize() -> Dictionary:
	return {
		"player_level": player_level,
		"player_xp": player_xp,
		"unlocked_features": unlocked_features,
		"completed_research": completed_research,
		"research_progress": research_progress
	}

## Deserialize from save data
func deserialize(data: Dictionary) -> void:
	player_level = data.get("player_level", 1)
	player_xp = data.get("player_xp", 0)
	unlocked_features = data.get("unlocked_features", [])
	completed_research = data.get("completed_research", [])
	research_progress = data.get("research_progress", {})
