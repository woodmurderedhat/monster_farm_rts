# Command Manager - Handles player commands to selected units
# Provides high-level command interface for RTS controls
extends Node
class_name CommandManager

## Reference to selection manager
var selection_manager: SelectionManager

## Reference to combat manager
var combat_manager: CombatManager


func _ready() -> void:
	# Connect to EventBus for command handling
	EventBus.player_command.connect(_on_player_command)


## Issue move command to selected units
func command_move(position: Vector2) -> void:
	if not selection_manager:
		return
	
	for monster in selection_manager.selected_monsters:
		if monster.has_method("command_move"):
			monster.command_move(position)


## Issue attack command to selected units
func command_attack(target: Node2D) -> void:
	if not selection_manager:
		return
	
	for monster in selection_manager.selected_monsters:
		if monster.has_method("command_attack"):
			monster.command_attack(target)
	
	# Set focus target in combat manager
	if combat_manager:
		combat_manager.set_focus_target(target)


## Issue stop command to selected units
func command_stop() -> void:
	if not selection_manager:
		return
	
	for monster in selection_manager.selected_monsters:
		if monster.has_method("command_stop"):
			monster.command_stop()


## Issue retreat command to selected units
func command_retreat() -> void:
	if not selection_manager or not combat_manager:
		return
	
	combat_manager.broadcast_combat_event("retreat", {})


## Issue hold position command
func command_hold() -> void:
	if not selection_manager or not combat_manager:
		return
	
	combat_manager.broadcast_combat_event("hold", {})


## Handle player command events
func _on_player_command(command_type: String, data: Dictionary) -> void:
	match command_type:
		"move":
			var position: Vector2 = data.get("position", Vector2.ZERO)
			command_move(position)
		"attack":
			var target: Node2D = data.get("target")
			if target:
				command_attack(target)
		"stop":
			command_stop()
		"retreat":
			command_retreat()
		"hold":
			command_hold()


func _unhandled_input(event: InputEvent) -> void:
	# Keyboard shortcuts for commands
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_S:
				command_stop()
			KEY_R:
				command_retreat()
			KEY_H:
				command_hold()

