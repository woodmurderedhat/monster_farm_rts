# Godot 4 Monster DNA Farm RTS – DNA Resource Schema & Validation Rules

---

## 1. Purpose of the DNA System

The DNA system is the **core content backbone** of the game.

Design goals:

* Infinite monster customization
* Fully data-driven
* Safe for mods
* Predictable for balance
* Validated automatically

DNA **never contains logic** — only data. All logic lives in systems that *interpret* DNA.

---

## 2. DNA Architecture Overview

Each monster is constructed from a **DNA Stack** composed of multiple DNA Resources.

```
Monster DNA Stack
 ├── DNACore
 ├── DNAElement (1–3)
 ├── DNABehavior (1)
 ├── DNAAbility (1–N)
 ├── DNAMutation (0–N)
```

Each layer is optional except  **DNACore** .

---

## 3. Base DNA Resource

All DNA types inherit from a shared base.

### BaseDNAResource

**Fields:**

* `id : String`
* `display_name : String`
* `description : String`
* `rarity : Enum (Common → Legendary)`
* `tags : Array[String]`
* `incompatible_tags : Array[String]`
* `stat_modifiers : Dictionary`
* `ai_modifiers : Dictionary`
* `visual_modifiers : Dictionary`

This allows generic handling and validation.

---

## 4. DNACoreResource (Required)

Defines the monster’s  **physical foundation** .

**Fields:**

* `body_type : Enum (Quadruped, Biped, Serpentine, Swarm)`
* `base_size : float`
* `base_mass : float`
* `movement_type : Enum (Ground, Flying, Burrowing)`
* `base_health : int`
* `base_stamina : int`
* `base_speed : float`
* `allowed_elements : Array[Enum]`
* `ability_slots : int`
* `mutation_capacity : int`

**Validation Rules:**

* Must exist
* Only one DNACore allowed
* Ability slots ≥ DNAAbility count

---

## 5. DNAElementResource

Defines elemental affinity and resistances.

**Fields:**

* `element_type : Enum (Fire, Water, Electric, Bio, Void, etc.)`
* `damage_bonus : float`
* `resistance_bonus : float`
* `status_effects : Array[Resource]`
* `environmental_interactions : Dictionary`

**Rules:**

* Max elements defined by DNACore
* Conflicting elements disallowed unless mutation permits

---

## 6. DNABehaviorResource

Defines personality and AI tendencies.

**Fields:**

* `aggression : float`
* `loyalty : float`
* `curiosity : float`
* `work_affinity : Dictionary`
* `combat_roles : Array[Enum]`
* `stress_tolerance : float`

**Rules:**

* Exactly one behavior profile
* Must define at least one combat role

---

## 7. DNAAbilityResource

Defines monster abilities.

**Fields:**

* `ability_id : String`
* `cooldown : float`
* `energy_cost : float`
* `range : float`
* `targeting_type : Enum`
* `scaling_stats : Array[String]`
* `required_tags : Array[String]`

**Rules:**

* Required tags must exist in DNA stack
* Ability count ≤ DNACore ability slots

---

## 8. DNAMutationResource

Defines unstable modifiers.

**Fields:**

* `mutation_type : Enum (Positive, Negative, Chaotic)`
* `instability_value : float`
* `override_rules : Dictionary`
* `forced_visuals : Dictionary`

**Rules:**

* Mutation count ≤ mutation capacity
* Instability threshold must not exceed core limits

---

## 9. DNA Stack Assembly Rules

During monster creation:

1. DNACore selected
2. Elements validated
3. Behavior assigned
4. Abilities slotted
5. Mutations applied

Order matters for validation and overrides.

---

## 10. Validation System

### 10.1 Validation Phases

* **Static Validation** (Editor-time)
* **Runtime Validation** (Spawn-time)

---

### 10.2 Static Validation Checks

* Missing required DNA layers
* Slot overflows
* Tag incompatibilities
* Invalid references
* Mod dependency checks

Errors block monster creation.
Warnings allow unstable builds.

---

### 10.3 Runtime Validation

* Environment conflicts
* Stability degradation
* Mutation escalation

Invalid runtime states trigger:

* Stat penalties
* Behavior shifts
* Feral transformation

---

## 11. Editor Tooling

### 11.1 DNA Inspector

* Layered DNA view
* Real-time stat preview
* Validation warnings

---

### 11.2 Monster Preview Generator

* Auto-builds monster scene
* Applies visuals
* Simulates combat role

---

## 12. Modding Considerations

* Mods add new DNA Resources
* No script inheritance required
* Validation system checks mod compatibility

Mods can:

* Add elements
* Add mutations
* Add abilities

They cannot:

* Break core schema

---

## 13. Balancing Hooks

* Global DNA scaling curves
* Rarity-based caps
* Zone-specific modifiers

Balance tweaks require  **data edits only** .

---

## 14. Failure & Emergence

Invalid or unstable DNA stacks can:

* Create feral monsters
* Trigger farm disasters
* Spawn rare DNA variants

Failure is a content generator.

---

## 15. Summary

* DNA is modular, layered, and validated
* Schema supports infinite expansion
* Validation protects stability without killing creativity
* System is mod-safe and designer-friendly

This DNA schema is the  **foundation of the entire game** .
