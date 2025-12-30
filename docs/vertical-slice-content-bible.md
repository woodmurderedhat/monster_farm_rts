# Godot 4 Monster DNA Farm RTS – Vertical Slice Content Bible

---

## 1. Purpose

This document defines the **minimum complete, shippable vertical slice** for the game.

The vertical slice is not a demo — it is a  **proof of system integrity** .

Goals:

* Validate all core systems working together
* Prove scalability and moddability
* Establish production standards

If the slice works, the full game is a matter of  *content* , not reinvention.

---

## 2. Design Philosophy of the Slice

The slice must:

* Use  **real systems** , not mockups
* Contain  **representative complexity** , not breadth
* Be playable for 30–60 minutes
* Generate emergent outcomes

No placeholder logic. Limited placeholder art only where unavoidable.

---

## 3. Core Pillars Covered

The slice must demonstrate:

* DNA harvesting & monster assembly
* Live-action RTS-style combat
* Farm automation & happiness loops
* World events & escalation
* Narrative reflection
* Save / load persistence
* Debug & developer tooling

---

## 4. World Scope

### 4.1 Overworld Biome (1)

**Biome:** Verdant Frontier

Features:

* Moderate predator/prey balance
* Elemental affinity: Nature
* Supports migration & instability events

Content:

* 3 monster species
* 1 elite variant
* 1 apex threat (event-gated)

---

### 4.2 Dungeon (1)

**Dungeon:** Rootbound Ruins

Rules:

* Tight corridors
* Reduced monster count cap
* Increased mutation chance

Rewards:

* Rare DNA fragments
* Unique ability modifier

---

### 4.3 Player Farm (1)

Features:

* Buildable enclosures
* Training zone
* Defense structures

Must support automation and raids.

---

## 5. Monster Content

### 5.1 Base Monsters (3)

Each monster must have:

* Unique DNA profile
* 1 passive ability
* 2 active abilities
* Distinct combat role

Examples:

* Sprigkin (fast skirmisher)
* Barkmaw (tank)
* Sporespawn (support)

---

### 5.2 Player-Assembled Monster (1)

Requirements:

* Built from at least 3 DNA fragments
* Demonstrates stat stacking
* Shows visual mutation layering

This is the  *proof monster* .

---

## 6. Abilities

Slice minimum:

* 6 active abilities
* 3 passives

Abilities must demonstrate:

* Cooldowns
* Targeting types
* VFX hooks
* AI & player usage parity

---

## 7. Combat & AI

### 7.1 Player Control

* Group selection
* Focus fire
* Ability hotkeys

### 7.2 AI Behaviors

* Threat evaluation
* Retreat logic
* Ability prioritization

Combat must feel readable under stress.

---

## 8. Farm Automation

Automation systems demonstrated:

* Task assignment
* Priority overrides
* Happiness effects
* Productivity tradeoffs

At least one automation failure state must be possible.

---

## 9. World Events (Minimum Set)

### 9.1 Event 1: Local Overgrowth

* Triggered by over-harvesting
* Increases monster aggression
* Leads to migration if ignored

---

### 9.2 Event 2: Migration Surge

* Moves monsters toward farm region
* Escalates to raid

---

### 9.3 Event 3: Farm Raid

* Tower-defense-style encounter
* Uses assembled monsters

---

## 10. Narrative Content

Narrative events:

* 3 world commentary messages
* 1 discovery log
* 1 farm reflection event

All optional, logged in codex.

---

## 11. Art & VFX Scope

### Art

* One tileset for overworld
* One tileset for farm
* One dungeon tileset

Monsters:

* Modular body parts
* Palette-swapped variants

---

### VFX

* Ability activation effects
* Damage indicators
* Event environmental effects

Must be signal-driven.

---

## 12. UI & UX

Required UI:

* Party control bar
* Farm overview panel
* World event tracker
* Monster detail view

Debug UI must be toggleable.

---

## 13. Save / Load Requirements

Slice must support:

* Save mid-world event
* Reload into active automation
* Persistent monster progression

No save-breaking actions allowed.

---

## 14. Debug & Developer Tools

Slice must include:

* Combat debug overlay
* World event inspector
* Save inspector

These are non-negotiable.

---

## 15. Modding Proof

Slice must demonstrate:

* One data-only mod
* One monster added via mod

No engine restart required.

---

## 16. Success Criteria

The slice is successful if:

* Systems interact without custom glue
* No crashes over long sessions
* Player choices create visible consequences
* Adding content feels straightforward

---

## 17. What the Slice Is NOT

* Not content-complete
* Not balanced
* Not polished visually

It is  **structurally complete** .

---

## 18. Summary

This Vertical Slice Content Bible:

* Defines the game’s irreducible core
* Eliminates architectural uncertainty
* Enables confident scaling

If this slice works, the game works.
