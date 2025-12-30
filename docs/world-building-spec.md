# Godot 4 Monster DNA Farm RTS – World Building Specification

---

## 1. Purpose

This document defines the **world structure, rules, and systemic design** of the game world, integrating:

* The Overworld (exploration & DNA acquisition)
* The Player Farm (management, automation, defense)
* Dungeons (high-risk, high-reward content)

Worldbuilding here is  **mechanical first** : lore, visuals, and content all serve gameplay systems.

---

## 2. Core World Design Pillars

### 2.1 One World, Three Modes

The game world is unified but expresses itself through three gameplay contexts:

1. **Overworld** – Exploration, quests, roaming threats
2. **Farm** – Persistent base, automation, defense
3. **Dungeons** – Instanced pressure chambers

Transitions are diegetic, not menu-driven.

---

### 2.2 Systemic Consistency

* Same monsters
* Same abilities
* Same stats
* Same AI

Only  **rulesets and pressures change** , not systems.

---

### 2.3 Living Ecology

The world is not static:

* Monsters migrate
* DNA prevalence shifts
* Raids originate logically

Player actions alter the world state.

---

## 3. Overworld Specification

### 3.1 Purpose

The overworld exists to:

* Supply DNA and resources
* Introduce narrative & quests
* Pressure the player to expand

It is the primary  *risk-reward loop* .

---

### 3.2 Map Structure

* Large continuous regions
* Soft biome borders
* Hand-authored landmarks

Example biomes:

* Fungal Forests
* Crystalline Plains
* Volcanic Badlands

---

### 3.3 Monster Presence

* Roaming packs
* Territorial elites
* Rare apex monsters

Each biome biases:

* DNA Elements
* Mutations
* Behavior traits

---

### 3.4 Exploration Gameplay

* RTS-style party control
* Player avatar supports monsters
* Environmental hazards

World events can escalate into raids.

---

### 3.5 Overworld Settlements & NPCs

* Quest hubs
* Traders
* Rival breeders

NPCs interact with the same DNA economy.

---

## 4. Player Farm Specification

### 4.1 Purpose

The farm is:

* The player’s anchor
* The automation sandbox
* The defense challenge

Time always advances here.

---

### 4.2 Spatial Structure

* Grid-based buildable area
* Expandable territory
* Zoning system

Zones include:

* Habitats
* Training yards
* Research labs
* Defensive perimeters

---

### 4.3 Automation & Life Simulation

Monsters at the farm:

* Work jobs
* Train skills
* Accumulate stress
* Form relationships

Happiness and efficiency are linked.

---

### 4.4 Farm Defense

* Periodic raids
* Threat scales with success
* Defensive jobs auto-assigned

Defense blends:

* Tower defense
* RTS combat
* Automation logic

---

### 4.5 Visual & Emotional Role

The farm visually evolves:

* New structures
* Monster diversity
* Signs of stress or prosperity

It is meant to feel  *alive* .

---

## 5. Dungeon Specification

### 5.1 Purpose

Dungeons exist to:

* Test monster builds
* Introduce rare DNA
* Provide high-stakes challenges

They are optional but lucrative.

---

### 5.2 Dungeon Structure

* Instanced maps
* Semi-procedural rooms
* Fixed thematic rules

Dungeon types:

* Mutation Labs
* Ancient Ruins
* Living Hives

---

### 5.3 Dungeon Rulesets

Dungeons apply modifiers:

* Limited healing
* Environmental effects
* Escalating enemy pressure

Rules are visible before entry.

---

### 5.4 Failure & Persistence

* Monsters can be injured or lost
* Partial rewards on failure
* Retreat always possible

Consequences persist back to farm.

---

## 6. World State & Progression

### 6.1 Regional Influence

Player actions affect regions:

* Monster population
* Raid frequency
* Resource scarcity

Ignoring threats has consequences.

---

### 6.2 Difficulty Scaling

Scaling is:

* Regional
* Time-based
* Player-driven

Over-farming attracts danger.

---

## 7. World Events

Examples:

* Monster migrations
* DNA storms
* Faction invasions

Events can affect overworld and farm simultaneously.

---

## 8. Lore Integration (Lightweight)

Lore explains systems:

* DNA manipulation is normal
* Farms are frontier outposts
* Dungeons are unstable remnants

Lore never overrides mechanics.

---

## 9. Godot 4 Technical Mapping

### Scene Separation

```
WorldRoot
 ├─ OverworldScene
 ├─ FarmScene
 └─ DungeonInstance
```

Shared systems:

* Monster scenes
* AI
* Combat
* VFX

---

## 10. Modding Hooks

Mods can add:

* Biomes
* Dungeon templates
* Farm buildings

World rules remain enforced.

---

## 11. Vertical Slice World Scope

For the slice:

* 1 biome region
* 1 farm map
* 1 dungeon

All transitions functional.

---

## 12. Common Failure Points

Avoid:

* Separate rulesets per mode
* Farm as menu-only
* Dungeons as stat checks

---

## 13. Summary

This world design:

* Keeps all systems unified
* Supports infinite expansion
* Grounds automation and combat
* Makes the world react to the player

The world is a  **pressure engine** , not a backdrop.
