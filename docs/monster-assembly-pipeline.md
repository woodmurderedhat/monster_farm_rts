# Godot 4 Monster DNA Farm RTS – Monster Assembly Pipeline (Spawn-Time Flow)

---

## 1. Purpose

This document defines the **exact runtime process** that converts a `MonsterDNAStack` into a fully functional monster entity in-game.

Goals:

* Deterministic, debuggable monster creation
* Clear separation between data and logic
* Support unstable / illegal DNA builds intentionally
* Reusable across world combat, farm simulation, raids, and previews

This pipeline runs:

* When a monster is incubated
* When a monster is summoned
* When a monster spawns in raids
* In editor preview tools

---

## 2. High-Level Flow Overview

```
Spawn Request
   ↓
Load Monster Scene
   ↓
Attach Components
   ↓
Validate DNA Stack
   ↓
Assemble Stats
   ↓
Configure AI
   ↓
Assign Abilities
   ↓
Apply Visuals
   ↓
Finalize & Activate
```

Each step is isolated, logged, and can fail gracefully.

---

## 3. Spawn Entry Points

### 3.1 Spawn Contexts

The pipeline accepts a  **SpawnContext** :

```gdscript
enum SpawnContext {
	WORLD,
	FARM,
	RAID,
	EDITOR_PREVIEW
}
```

Context affects:

* Validation strictness
* Instability tolerance
* AI defaults

---

## 4. Step-by-Step Assembly

### 4.1 Load Base Monster Scene

* Load `res://entities/monster/monster_base.tscn`
* Scene contains no gameplay configuration
* Only structural components

Result: Empty monster shell

---

### 4.2 Attach & Initialize Components

Required components:

* HealthComponent
* CombatComponent
* AIComponent
* JobComponent
* ProgressionComponent
* DNAComponent

Components register themselves with the monster root.

---

### 4.3 DNA Validation Phase

* Run shared validation framework
* Receive `Array[ValidationResult]`

Rules:

* **Errors** block spawn (except in preview)
* **Warnings** allow spawn with instability flags

Invalid monsters can:

* Fail to spawn
* Spawn unstable
* Spawn feral

---

### 4.4 Stat Assembly Phase

Stats are built in layers:

1. Base stats from `DNACore`
2. Additive modifiers from all DNA layers
3. Multiplicative modifiers
4. Context modifiers (zone, difficulty)
5. Instability penalties

All calculations stored in a `StatBlock` object.

No component calculates stats independently.

---

### 4.5 AI Configuration Phase

AI is configured from DNA, not scripted.

Inputs:

* DNABehaviorResource
* DNA tags
* SpawnContext

AIComponent configures:

* Default state
* Combat role weights
* Job preferences
* Stress behavior

Unstable builds may override AI rules.

---

### 4.6 Ability Assignment Phase

* Read DNAAbilityResources
* Instantiate ability runtime objects
* Validate ability requirements
* Bind to CombatComponent

Ability order matters for AI prioritization.

Invalid abilities:

* Disabled
* Replaced with fallback
* Cause instability

---

### 4.7 Visual Assembly Phase

Visuals are composed from DNA:

* Base sprite by body_type
* Overlays for elements
* Forced visuals from mutations
* Size and color modulation

Visual system reads `visual_modifiers` only.

---

### 4.8 Finalization Phase

* Apply health and stamina caps
* Reset cooldowns
* Emit `monster_spawned` signal
* Enable AI and physics

Monster becomes active.

---

## 5. Error Handling & Fallbacks

If assembly fails mid-pipeline:

* Roll back partial setup
* Log detailed error
* Spawn placeholder entity if allowed

Preview context never crashes.

---

## 6. Instability & Emergence Hooks

Instability score is calculated during assembly.

High instability can:

* Modify stats
* Change AI state
* Add hidden mutations
* Cause delayed feral events

Instability is  **data-driven** , not random.

---

## 7. Determinism & Save Safety

* DNA stack is the only serialized source
* Monster runtime state is derived
* Rebuilding from DNA always yields same result

This guarantees:

* Save compatibility
* Mod updates don’t corrupt saves

---

## 8. Pseudocode Overview

```gdscript
func assemble_monster(dna: MonsterDNAStack, context: SpawnContext) -> Node2D:
	var monster = load_base_scene()
	attach_components(monster)

	var results = validate_dna(dna, context)
	if has_blocking_errors(results):
		return null

	var stats = build_stats(dna, context)
	monster.stats = stats

	configure_ai(monster, dna, context)
	assign_abilities(monster, dna)
	apply_visuals(monster, dna)

	finalize(monster)
	return monster
```

---

## 9. Integration with Editor Tools

This pipeline is reused by:

* Monster Preview Generator
* Ability Sandbox
* Validation Inspector

No duplicate logic.

---

## 10. Performance Considerations

* Assembly occurs infrequently
* Heavy work cached
* Runtime monsters do not recompute DNA

---

## 11. Extension Points

Mods can:

* Add new DNA layers
* Add new stat modifiers
* Add new visual hooks

Core pipeline remains unchanged.

---

## 12. Summary

The Monster Assembly Pipeline:

* Is deterministic and safe
* Makes DNA the single source of truth
* Supports instability and emergence
* Works everywhere monsters exist

This pipeline is the **engine heart** of the game.
