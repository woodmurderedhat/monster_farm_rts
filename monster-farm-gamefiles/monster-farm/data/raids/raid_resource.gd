## Raid Resource - defines a raid event configuration
## Used by RaidManager to spawn and manage raid waves
extends Resource
class_name RaidResource

@export var raid_id: String = ""
@export var raid_name: String = ""
@export var description: String = ""

## Difficulty
@export_range(1, 10) var difficulty_level: int = 1

## Wave configuration
@export var wave_count: int = 3
@export var time_between_waves: float = 30.0  # Seconds

## Spawn configuration
@export var spawn_positions: Array[Vector2] = []  # Where enemies spawn
@export var enemy_dna_pools: Array[Resource] = []  # DNA resources to use for enemies

## Wave composition (per wave)
@export var enemies_per_wave: Array[int] = [5, 7, 10]
@export var wave_elite_chance: Array[float] = [0.0, 0.2, 0.5]  # Chance of elite enemies

## Rewards
@export var xp_reward: int = 100
@export var dna_rewards: Array[Resource] = []
@export var unlock_rewards: Array[String] = []  # Feature/zone IDs to unlock

## Trigger conditions
@export var required_player_level: int = 1
@export var can_trigger_randomly: bool = true
@export var random_trigger_weight: float = 1.0
