# Godot 4 Monster DNA Farm RTS – Technical Architecture Document

---

## 1. Technical Vision & Goals

This document defines the **technical architecture** for the Monster DNA Farm RTS, focusing on:

* **Modularity** – systems are isolated, replaceable, and extendable
* **Scalability** – easy to add new content without refactoring core code
* **Moddability** – data-driven design, minimal hard-coded logic
* **Automation** – workflows that reduce friction for design, testing, and iteration

The architecture is designed explicitly for **Godot 4 (latest stable)** and  **2D top-down gameplay** .

---

## 2. Core Architectural Principles

### 2.1 Data-Driven First

* Gameplay logic reacts to data, not the other way around
* Monsters, DNA, jobs, buildings, abilities, and zones are  **Resources** , not scripts
* Designers can add content without touching code

### 2.2 Composition Over Inheritance

* Entities are composed of modular components
* Avoid deep inheritance trees
* Prefer small, reusable behaviors

### 2.3 Clear Separation of Concerns

* World, Farm, Combat, AI, and UI are isolated modules
* Systems communicate via  **signals and events** , not direct references

---

## 3. High-Level Project Structure

```
res://
 ├── core/
 │    ├── globals/
 │    ├── events/
 │    ├── save/
 │    └── mod_loader/
 │
 ├── data/
 │    ├── dna/
 │    ├── monsters/
 │    ├── abilities/
 │    ├── jobs/
 │    ├── buildings/
 │    ├── zones/
 │    └── raids/
 │
 ├── systems/
 │    ├── combat/
 │    ├── ai/
 │    ├── automation/
 │    ├── farm/
 │    ├── world/
 │    └── progression/
 │
 ├── entities/
 │    ├── monster/
 │    ├── player/
 │    ├── npc/
 │    └── structures/
 │
 ├── ui/
 ├── scenes/
 ├── tools/
 └── mods/
```

---

## 4. Core Game Loop Architecture

### 4.1 Game States

* Main Menu
* World Exploration
* Farm Simulation
* Raid Defense

Managed by a **GameStateManager** singleton.

Transitions do not destroy global systems; they enable/disable modules.

---

## 5. Entity Architecture

### 5.1 Base Entity

All interactive objects inherit from a lightweight base:

* Node2D / CharacterBody2D
* Unique ID
* Signal hooks

No gameplay logic here.

---

### 5.2 Component-Based Composition

Entities gain functionality via components:

* HealthComponent
* MovementComponent
* CombatComponent
* JobComponent
* AIComponent
* ProgressionComponent

Components are Nodes added as children.

---

## 6. Monster Architecture

### 6.1 Monster Scene

```
Monster (CharacterBody2D)
 ├── Sprite / Animation
 ├── HealthComponent
 ├── CombatComponent
 ├── AIComponent
 ├── JobComponent
 ├── DNAComponent
 ├── ProgressionComponent
```

Monsters are **runtime assemblies** driven by DNA Resources.

---

### 6.2 DNA System Implementation

DNA is stored as  **Resource assets** :

* DNACoreResource
* DNAElementResource
* DNABehaviorResource
* DNAAbilityResource
* DNAMutationResource

Monsters read DNA at spawn time to configure:

* Stats
* Abilities
* AI parameters
* Visual modifiers

DNA never directly controls logic.

---

## 7. AI Architecture

### 7.1 AI Stack

* **State Machines** for high-level modes (Idle, Combat, Work)
* **Behavior Trees** for decision-making
* **Utility Scores** for priority selection

AI logic is fully data-driven via Resources.

---

### 7.2 Job & Automation AI

* Job definitions are Resources
* Monsters query a JobManager
* Priority-based task assignment
* Area and condition filters

Automation rules are evaluated at fixed intervals.

---

## 8. Combat System Architecture

### 8.1 Ability System

Abilities are modular Resources:

* Cooldowns
* Targeting rules
* Effects

Abilities emit events; effects apply results.

---

### 8.2 RTS Command Layer

* Player issues commands via CommandManager
* Commands override AI temporarily
* AI resumes when command expires

---

## 9. Farm Simulation & Defense

### 9.1 Farm Map

* TileMap-based
* NavigationRegion2D for pathfinding
* Zones defined via Area2D

---

### 9.2 Raid System

* Raid definitions are Resources
* Spawn waves via WaveController
* Path selection via NavigationAgent2D

---

## 10. World System

* Zones loaded as scenes
* Streaming via PackedScenes
* Persistent world state via SaveManager

World changes are event-driven.

---

## 11. UI Architecture

* MVC-inspired
* UI reads game state, never mutates it directly
* Signals used for updates

---

## 12. Save & Persistence

* Custom SaveManager
* JSON or binary serialization
* Versioned save files
* Supports mod data

---

## 13. Modding Support

### 13.1 Mod Structure

```
mods/
 ├── example_mod/
 │    ├── data/
 │    ├── scenes/
 │    ├── scripts/
 │    └── manifest.json
```

### 13.2 Mod Loader

* Loads Resources dynamically
* Registers content with systems
* Supports overrides and extensions

No recompilation required.

---

## 14. Automated Workflows

### 14.1 Content Validation Tools

* DNA consistency checks
* Ability dependency validation
* Missing reference detection

---

### 14.2 Editor Tools

* Custom inspectors for DNA
* Monster preview generator
* Farm simulation test mode

---

### 14.3 Build Automation

* Export presets per platform
* Automated test scenes
* Data-only hot reload support

---

## 15. Testing Strategy

* Unit tests for systems
* Simulation stress tests
* Automated raid simulations

Failures should generate logs and metrics.

---

## 16. Performance Considerations

* Object pooling for monsters & effects
* Batched AI updates
* Tick-based simulation scaling

---

## 17. Expansion Strategy

New content requires:

* New Resources
* Optional new scenes
* No core code changes

The architecture supports:

* New monster mechanics
* New farm systems
* New world zones

---

## 18. Technical Design Summary

* Godot-native, data-driven architecture
* Modular systems with clear boundaries
* Strong modding and automation support
* Built for long-term expansion and experimentation

This architecture prioritizes  **flexibility over premature optimization** , enabling the game to grow without collapse.
