# Godot 4 Monster DNA Farm RTS – Biome & Dungeon Data Schema

---

## 1. Purpose

This document defines the **data-driven schema** for **Biomes** (overworld regions) and **Dungeons** (instanced challenge spaces).

The schema is designed to be:

* Godot 4–native (Resources-first)
* Fully moddable
* Validatable
* Systemically integrated with DNA, AI, combat, and world events

No biome or dungeon contains hardcoded logic.

---

## 2. Core Design Principles

### 2.1 Data, Not Code

* Biomes and dungeons are pure data
* Behavior emerges from modifiers and weights
* Code reads data, never branches on IDs

---

### 2.2 Shared Foundations

Biomes and dungeons share:

* DNA pools
* Spawn rules
* Environmental modifiers

Dungeons are  **constrained biomes with extra rules** .

---

## 3. Biome Resource Schema

### 3.1 BiomeResource (Primary)

```gdscript
extends Resource
class_name BiomeResource

@export var biome_id: String
@export var display_name: String
@export var description: String

@export var visual_profile: BiomeVisualProfile
@export var dna_profile: BiomeDNAProfile
@export var spawn_profile: BiomeSpawnProfile
@export var environment_profile: EnvironmentModifierProfile
@export var event_profile: BiomeEventProfile

@export var difficulty_rating: float
@export var discovery_weight: float
```

---

### 3.2 BiomeVisualProfile

```gdscript
extends Resource
class_name BiomeVisualProfile

@export var ground_tileset: PackedScene
@export var prop_sets: Array[PackedScene]
@export var ambient_vfx: PackedScene
@export var color_palette: Color
```

Controls look only — no gameplay.

---

### 3.3 BiomeDNAProfile

Defines  **what DNA appears here** .

```gdscript
extends Resource
class_name BiomeDNAProfile

@export var element_weights: Dictionary # Element → weight
@export var mutation_weights: Dictionary # Mutation → weight
@export var rarity_curve: Curve
```

Used for:

* Monster spawns
* Loot drops
* Dungeon seeding

---

### 3.4 BiomeSpawnProfile

```gdscript
extends Resource
class_name BiomeSpawnProfile

@export var pack_size_range: Vector2i
@export var elite_chance: float
@export var apex_chance: float

@export var aggression_bias: float
@export var migration_rate: float
```

Influences AI behavior and population flow.

---

### 3.5 EnvironmentModifierProfile

Applies **global stat modifiers** while in biome.

```gdscript
extends Resource
class_name EnvironmentModifierProfile

@export var stat_modifiers: Array[StatModifier]
@export var hazard_frequency: float
@export var visibility_modifier: float
```

Examples:

* Heat damage over time
* Reduced vision

---

### 3.6 BiomeEventProfile

```gdscript
extends Resource
class_name BiomeEventProfile

@export var possible_events: Array[WorldEventResource]
@export var event_frequency: float
```

Events can escalate into raids.

---

## 4. Dungeon Resource Schema

### 4.1 DungeonResource (Primary)

```gdscript
extends Resource
class_name DungeonResource

@export var dungeon_id: String
@export var display_name: String
@export var description: String

@export var base_biome: BiomeResource
@export var dungeon_rules: DungeonRuleProfile
@export var room_profile: DungeonRoomProfile
@export var reward_profile: DungeonRewardProfile

@export var risk_rating: float
```

A dungeon is  **a biome plus constraints** .

---

### 4.2 DungeonRuleProfile

```gdscript
extends Resource
class_name DungeonRuleProfile

@export var global_stat_modifiers: Array[StatModifier]
@export var healing_allowed: bool
@export var retreat_allowed: bool

@export var escalation_rate: float
```

Rules are shown before entry.

---

### 4.3 DungeonRoomProfile

```gdscript
extends Resource
class_name DungeonRoomProfile

@export var room_templates: Array[PackedScene]
@export var min_rooms: int
@export var max_rooms: int

@export var branching_factor: float
```

Supports semi-procedural layouts.

---

### 4.4 DungeonRewardProfile

```gdscript
extends Resource
class_name DungeonRewardProfile

@export var guaranteed_dna: Array[DNAResource]
@export var rare_dna_chance: float

@export var artifact_loot: Array[Resource]
```

High-risk, high-reward tuning lives here.

---

## 5. Validation Rules

### 5.1 Biome Validation

* Must define at least one DNA element
* Spawn weights must sum > 0
* Difficulty must match spawn strength

---

### 5.2 Dungeon Validation

* Must reference a base biome
* Cannot disable both healing and retreat unless flagged lethal
* Reward value must scale with risk_rating

---

## 6. Runtime Usage Flow

### Biome Selection

```
World Seed → Biome Weights → Region Generation
```

### Dungeon Generation

```
DungeonResource → BaseBiome → Apply Rules → Generate Rooms
```

---

## 7. Modding Support

Mods can:

* Add biomes
* Add dungeon templates
* Extend DNA pools

Validation prevents breaking balance.

---

## 8. Vertical Slice Data Scope

* 1 biome resource
* 1 dungeon resource
* 2 events
* 5 DNA entries

---

## 9. Common Pitfalls

Avoid:

* Biomes as art-only
* Dungeons with bespoke logic
* Hardcoded spawn tables

---

## 10. Summary

This schema:

* Makes the world fully data-driven
* Keeps systems unified
* Enables infinite expansion
* Supports modders safely

Biomes and dungeons become  **configuration, not code** .
