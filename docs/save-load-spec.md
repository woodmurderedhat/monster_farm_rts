# Godot 4 Monster DNA Farm RTS – Save / Load & World Persistence Specification

---

## 1. Purpose

This document defines how  **game state is persisted, restored, and evolved over time** .

Goals:

* Persist a living, reactive world
* Support long-running systemic consequences
* Enable mod compatibility and forward versioning
* Avoid brittle hard-coded save logic

Persistence is  **data-driven, layered, and resilient** .

---

## 2. Core Persistence Principles

### 2.1 World State Is Canonical

* The save file stores  **world state** , not replay instructions
* Systems rebuild runtime objects from state

---

### 2.2 Determinism Over Serialization

* Do not serialize nodes directly
* Serialize **Resources + primitive data**

Nodes are reconstructed on load.

---

### 2.3 Layered Persistence

```
Global World
 ├─ Regions / Biomes
 │   ├─ Active Events
 │   ├─ Population Metrics
 │
 ├─ Player Farm
 │   ├─ Structures
 │   ├─ Monsters
 │   ├─ Automation State
 │
 └─ Player Profile
     ├─ Unlocks
     ├─ Knowledge
```

---

## 3. Save Slot Structure

```
save_slot_X/
 ├─ meta.json
 ├─ world_state.json
 ├─ farm_state.json
 ├─ player_state.json
 └─ mod_state.json
```

Each file is independently loadable.

---

## 4. Global Save Metadata

```json
{
  "save_version": "0.1.0",
  "godot_version": "4.x",
  "timestamp": 123456789,
  "mods_enabled": ["core", "example_mod"],
  "playtime": 36000
}
```

Used for migration and validation.

---

## 5. World State Schema

### 5.1 WorldState

```json
{
  "regions": [ ... ],
  "global_flags": { "dna_instability": 0.3 }
}
```

---

### 5.2 RegionState

```json
{
  "region_id": "ashen_wastes",
  "biome_id": "volcanic",
  "population_metrics": {
    "predator_density": 0.7,
    "prey_density": 0.2
  },
  "active_events": ["migration_event_01"],
  "permanent_modifiers": ["scarred_terrain"]
}
```

---

## 6. World Event Persistence

Each active event stores:

```json
{
  "event_id": "apex_migration",
  "phase": "active",
  "time_remaining": 1200,
  "escalation_level": 2
}
```

Events resume mid-phase.

---

## 7. Player Farm State

### 7.1 Structures

```json
{
  "structure_id": "enclosure_large",
  "position": [12, 5],
  "level": 3,
  "assigned_monsters": ["m_001", "m_002"]
}
```

---

### 7.2 Monster Persistence

```json
{
  "monster_uid": "m_001",
  "dna_profile": "dna_hash_ABC",
  "level": 12,
  "stats": { "hp": 120, "atk": 35 },
  "abilities": ["fire_breath"],
  "current_task": "guard"
}
```

Monsters are reconstructed via the  **Monster Assembly Pipeline** .

---

## 8. Automation & AI State

Persist:

* Current task assignments
* Priority overrides
* Cooldowns & internal timers

Do NOT persist:

* Pathfinding state
* Behavior trees

AI resumes naturally.

---

## 9. Player State

```json
{
  "unlocked_biomes": ["forest", "volcanic"],
  "known_dna": ["fire", "wing"],
  "research_progress": {
    "mutation": 0.4
  }
}
```

---

## 10. Dungeon Persistence Rules

Dungeons:

* Are ephemeral
* Only persist **completion state and modifiers**

```json
{
  "dungeon_id": "ruined_core",
  "completed": true,
  "difficulty_modifier": 1.3
}
```

No mid-dungeon saving (by default).

---

## 11. Mod State Persistence

Mods may store:

* Custom flags
* Custom world metrics

Stored under:

```json
mod_state: {
  "mod_id": { ... }
}
```

Core systems never read mod internals.

---

## 12. Versioning & Migration

* Each save includes version tag
* Migration scripts map old → new schemas
* Unknown fields are ignored, not fatal

Backward compatibility is prioritized.

---

## 13. Godot 4 Runtime Architecture

### Managers

```
SaveManager (AutoLoad)
 ├─ Serializer
 ├─ Deserializer
 ├─ MigrationManager
```

---

### Save Flow

```
Pause → Collect State → Validate → Write Files
```

---

### Load Flow

```
Read Files → Validate → Rebuild World → Resume
```

---

## 14. Debug & Validation Tools

* Save inspector UI
* World diff comparison
* Corruption detection

Designed to support QA and modders.

---

## 15. Vertical Slice Requirements

Slice must persist:

* 1 biome
* 1 world event mid-phase
* Farm with automation
* 3 monsters

---

## 16. Common Failure Points

Avoid:

* Node serialization
* Hidden state
* Save-breaking refactors

---

## 17. Summary

This Save / Load system:

* Preserves a living world
* Scales with systemic complexity
* Supports mods and iteration
* Survives long development cycles

Persistence is  **infrastructure, not a feature** .
