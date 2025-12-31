# EventBus - Global signal hub for cross-system communication
# Autoload singleton for decoupled event handling
@warning_ignore("unused_signal")  # Signals are consumed dynamically across the project
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

# ==== Progression Events ====
## Emitted when monster levels up
signal monster_leveled_up(monster: Node, new_level: int)

## Emitted when player levels up
signal player_leveled_up(new_level: int)

## Emitted when research is completed
signal research_completed(research_id: String)

## Emitted when feature is unlocked
signal feature_unlocked(feature_id: String)

# ==== World Events ====
## Emitted when world event triggers
signal world_event_triggered(event: Resource)

## Emitted when world event phase changes
signal world_event_phase_changed(event: Resource, phase: String)

## Emitted when world event resolves
signal world_event_resolved(event: Resource)

# ==== Zone Events ====
## Emitted when zone is unlocked
signal zone_unlocked(zone_id: String)

## Emitted when zone is entered
signal zone_entered(zone_id: String)

## Emitted when zone is discovered for first time
signal zone_discovered(zone_id: String)

## Emitted when zone corruption changes
signal zone_corruption_changed(zone_id: String, corruption_level: float)

## Emitted when zone DNA availability changes
signal zone_dna_availability_changed(zone_id: String, modifiers: Dictionary)

## Emitted when a zone is cleared of threats
signal zone_cleared(zone_id: String)

# ==== Narrative Events ====
## Emitted when narrative popup requested
signal narrative_popup_requested(data: Dictionary)

## Emitted when log message added
signal log_message_added(data: Dictionary)

## Emitted when NPC message received
signal npc_message_received(data: Dictionary)

# ==== Automation Events ====
## Emitted when monster is assigned a job
signal monster_job_assigned(monster: Node, job: Resource)

## Emitted when spawn rates are modified by events
signal spawn_rates_modified(modifiers: Dictionary)

# ==== Player Ability Events ====
## Emitted when player casts ability
signal player_ability_cast(ability_id: String, target: Node)

## Emitted when player is damaged
signal player_damaged(amount: float, source: Node)

## Emitted when player is healed
signal player_healed(amount: float)

## Emitted when player dies
signal player_died()

## Emitted when monster is buffed
signal monster_buffed(monster: Node, buff_type: String, multiplier: float, duration: float)

## Emitted when enemy is stunned
signal enemy_stunned(enemy: Node, duration: float)
