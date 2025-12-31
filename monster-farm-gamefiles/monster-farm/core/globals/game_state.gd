# GameState - Global game state manager
# Autoload singleton for managing game state and transitions
extends Node

## Game state enum
enum State {
	MAIN_MENU,
	WORLD_EXPLORATION,
	FARM_SIMULATION,
	RAID_DEFENSE,
	PAUSED
}

## Current game state
var current_state: State = State.MAIN_MENU

## Previous state (for unpausing)
var previous_state: State = State.MAIN_MENU

## Whether game is paused
var is_paused: bool = false

## Current farm data
var current_farm: Dictionary = {}

## Player's monster collection
var owned_monsters: Array[Resource] = []

## Collected DNA stacks
var dna_collection: Array[Resource] = []

# Lightweight player progression/state snapshot
var player_state: Dictionary = {
	"gold": 0,
	"total_xp": 0,
	"level": 1
}

# World time tracking used by UI
var current_day: int = 1
var current_period: String = "Dawn"

# Session timing (used for playtime bookkeeping)
var session_start_time: int = 0
var playtime: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	session_start_time = int(Time.get_unix_time_from_system())
	playtime = 0


## Initialize a fresh game session from the main menu
func start_new_game() -> void:
	# Reset stateful data so new sessions do not leak prior runs
	current_farm = {
		"name": "Starter Farm",
		"level": 1,
		"resources": {
			"wood": 120,
			"stone": 90,
			"metal": 60,
			"herbs": 80
		},
		"unlocked_buildings": [],
		"active_jobs": []
	}
	owned_monsters.clear()
	dna_collection.clear()
	player_state = {
		"gold": 0,
		"total_xp": 0,
		"level": 1
	}
	current_day = 1
	current_period = "Dawn"
	previous_state = State.MAIN_MENU
	is_paused = false
	get_tree().paused = false
	session_start_time = int(Time.get_unix_time_from_system())
	playtime = 0

	change_state(State.WORLD_EXPLORATION)


## Change game state
func change_state(new_state: State) -> void:
	if new_state == current_state:
		return
	
	previous_state = current_state
	current_state = new_state
	
	var eb = get_node_or_null("/root/EventBus")
	if eb and eb.has_signal("game_state_changed"):
		eb.emit_signal("game_state_changed", _state_to_string(new_state))


## Toggle pause
func toggle_pause() -> void:
	set_paused(not is_paused)


## Set pause state
func set_paused(paused: bool) -> void:
	if paused == is_paused:
		return
	
	is_paused = paused
	get_tree().paused = paused
	var eb = get_node_or_null("/root/EventBus")
	if eb and eb.has_signal("pause_state_changed"):
		eb.emit_signal("pause_state_changed", is_paused)


## Check if in combat state
func is_in_combat() -> bool:
	return current_state == State.WORLD_EXPLORATION or current_state == State.RAID_DEFENSE


## Check if in farm state
func is_in_farm() -> bool:
	return current_state == State.FARM_SIMULATION


## Add a monster to collection
func add_monster(dna_stack: Resource) -> void:
	owned_monsters.append(dna_stack)
	var eb = get_node_or_null("/root/EventBus")
	if eb and eb.has_signal("game_state_changed"):
		eb.emit_signal("game_state_changed", _state_to_string(current_state))


## Add DNA to collection
func add_dna(dna: Resource) -> void:
	dna_collection.append(dna)
	var eb = get_node_or_null("/root/EventBus")
	if eb and eb.has_signal("game_state_changed"):
		eb.emit_signal("game_state_changed", _state_to_string(current_state))


## Get state as string
func _state_to_string(state: State) -> String:
	match state:
		State.MAIN_MENU: return "main_menu"
		State.WORLD_EXPLORATION: return "world"
		State.FARM_SIMULATION: return "farm"
		State.RAID_DEFENSE: return "raid"
		State.PAUSED: return "paused"
		_: return "unknown"
