# EventBus - Global signal hub for cross-system communication
# Autoload singleton for decoupled event handling
extends Node

# ==== Monster Events ====
## Emitted when a monster is spawned
signal monster_spawned(monster: Node2D)

## Emitted when a monster dies
signal monster_died(monster: Node2D)

## Emitted when a monster is selected
signal monster_selected(monster: Node2D)

## Emitted when a monster is deselected
signal monster_deselected(monster: Node2D)

## Emitted when selection is cleared
signal selection_cleared

# ==== Combat Events ====
## Emitted when combat starts
signal combat_started

## Emitted when combat ends
signal combat_ended

## Emitted when damage is dealt
signal damage_dealt(attacker: Node2D, target: Node2D, amount: float)

## Emitted when an ability is used
signal ability_used(user: Node2D, ability_id: String, target: Node)

# ==== Farm Events ====
## Emitted when a job is posted
signal job_posted(job_data: Dictionary)

## Emitted when a job is claimed
signal job_claimed(job_data: Dictionary, worker: Node2D)

## Emitted when a job is completed
signal job_completed(job_data: Dictionary, worker: Node2D)

## Emitted when farm state changes
signal farm_state_changed

# ==== Raid Events ====
## Emitted when a raid starts
signal raid_started(raid_data: Dictionary)

## Emitted when a raid wave spawns
signal raid_wave_spawned(wave_number: int)

## Emitted when a raid ends
signal raid_ended(success: bool)

# ==== Player Events ====
## Emitted when player issues a command
signal player_command(command_type: String, data: Dictionary)

## Emitted when player clicks on world
signal world_clicked(position: Vector2, button: int)

## Emitted when player drags selection box
signal selection_box_drawn(rect: Rect2)

# ==== UI Events ====
## Emitted when UI panel opens
signal ui_panel_opened(panel_name: String)

## Emitted when UI panel closes
signal ui_panel_closed(panel_name: String)

# ==== Game State Events ====
## Emitted when game state changes
signal game_state_changed(new_state: String)

## Emitted when game is paused/unpaused
signal pause_state_changed(is_paused: bool)

## Emitted when game is saved
signal game_saved

## Emitted when game is loaded
signal game_loaded

