## Game State Manager - manages game modes and state transitions
## Coordinates between exploration, farm, raid, and menu states
extends Node
class_name GameStateManager

signal state_changed(old_state: String, new_state: String)
signal game_paused(paused: bool)

enum GameMode {
	MAIN_MENU,
	WORLD_EXPLORATION,
	FARM_SIMULATION,
	RAID_DEFENSE,
	DUNGEON,
	PAUSED
}

var current_state: GameMode = GameMode.MAIN_MENU
var previous_state: GameMode = GameMode.MAIN_MENU
var is_paused: bool = false

## State-specific managers (enabled/disabled per state)
var active_managers: Dictionary = {
	"combat": null,
	"farm": null,
	"world_event": null,
	"raid": null,
	"zone": null
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Always process even when paused

## Change game state
func change_state(new_state: GameMode) -> void:
	if new_state == current_state:
		return
	
	var old_state = current_state
	_exit_state(current_state)
	
	previous_state = current_state
	current_state = new_state
	
	_enter_state(new_state)
	
	state_changed.emit(_state_to_string(old_state), _state_to_string(new_state))
	EventBus.game_state_changed.emit(_state_to_string(new_state))

## Exit current state
func _exit_state(state: GameMode) -> void:
	match state:
		GameMode.WORLD_EXPLORATION:
			_disable_world_systems()
		GameMode.FARM_SIMULATION:
			_disable_farm_systems()
		GameMode.RAID_DEFENSE:
			_disable_raid_systems()
		GameMode.DUNGEON:
			_disable_dungeon_systems()

## Enter new state
func _enter_state(state: GameMode) -> void:
	match state:
		GameMode.MAIN_MENU:
			_enable_menu()
		GameMode.WORLD_EXPLORATION:
			_enable_world_systems()
		GameMode.FARM_SIMULATION:
			_enable_farm_systems()
		GameMode.RAID_DEFENSE:
			_enable_raid_systems()
		GameMode.DUNGEON:
			_enable_dungeon_systems()

## Enable world exploration systems
func _enable_world_systems() -> void:
	_set_manager_active("combat", true)
	_set_manager_active("world_event", true)
	_set_manager_active("zone", true)
	
	# Player character is active
	if has_node("/root/GameWorld/Player"):
		get_node("/root/GameWorld/Player").set_process(true)
		get_node("/root/GameWorld/Player").set_physics_process(true)

## Disable world exploration systems
func _disable_world_systems() -> void:
	_set_manager_active("world_event", false)

## Enable farm simulation systems
func _enable_farm_systems() -> void:
	_set_manager_active("farm", true)
	_set_manager_active("combat", false)  # Farm is peaceful (unless raid)
	
	# Activate automation
	if has_node("/root/GameWorld/FarmManager/AutomationScheduler"):
		var scheduler = get_node("/root/GameWorld/FarmManager/AutomationScheduler")
		scheduler.set_process(true)

## Disable farm simulation systems
func _disable_farm_systems() -> void:
	# Don't fully disable farm - it continues in background
	# Just pause automation updates
	if has_node("/root/GameWorld/FarmManager/AutomationScheduler"):
		var scheduler = get_node("/root/GameWorld/FarmManager/AutomationScheduler")
		scheduler.set_process(false)

## Enable raid defense systems
func _enable_raid_systems() -> void:
	_set_manager_active("raid", true)
	_set_manager_active("combat", true)
	_set_manager_active("farm", true)  # Farm monsters participate

## Disable raid systems
func _disable_raid_systems() -> void:
	_set_manager_active("raid", false)

## Enable dungeon systems
func _enable_dungeon_systems() -> void:
	_set_manager_active("combat", true)
	# Dungeons are like mini-worlds with special rules

## Disable dungeon systems
func _disable_dungeon_systems() -> void:
	pass

## Enable menu
func _enable_menu() -> void:
	# Pause all game systems
	set_paused(true)

## Set manager active state
func _set_manager_active(manager_key: String, active: bool) -> void:
	if active_managers.has(manager_key) and active_managers[manager_key] != null:
		var manager = active_managers[manager_key]
		if is_instance_valid(manager):
			manager.set_process(active)

## Pause/unpause game
func set_paused(paused: bool) -> void:
	is_paused = paused
	get_tree().paused = paused
	game_paused.emit(paused)

## Toggle pause
func toggle_pause() -> void:
	set_paused(not is_paused)

## Check current state
func is_in_state(state: GameMode) -> bool:
	return current_state == state

## Get current state as string
func get_current_state_string() -> String:
	return _state_to_string(current_state)

## Convert state enum to string
func _state_to_string(state: GameMode) -> String:
	match state:
		GameMode.MAIN_MENU:
			return "main_menu"
		GameMode.WORLD_EXPLORATION:
			return "world_exploration"
		GameMode.FARM_SIMULATION:
			return "farm_simulation"
		GameMode.RAID_DEFENSE:
			return "raid_defense"
		GameMode.DUNGEON:
			return "dungeon"
		GameMode.PAUSED:
			return "paused"
	return "unknown"

## Quick state transitions
func enter_world() -> void:
	change_state(GameMode.WORLD_EXPLORATION)

func enter_farm() -> void:
	change_state(GameMode.FARM_SIMULATION)

func start_raid() -> void:
	change_state(GameMode.RAID_DEFENSE)

func enter_dungeon() -> void:
	change_state(GameMode.DUNGEON)

func return_to_menu() -> void:
	change_state(GameMode.MAIN_MENU)

## Register managers for state control
func register_manager(key: String, manager: Node) -> void:
	active_managers[key] = manager
