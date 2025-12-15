# Godot 4 Monster DNA Farm RTS – Vertical Slice Build Plan

---

## 1. Purpose

This document defines a **practical, implementation-first Vertical Slice plan** for building the game in  **Godot 4 (latest)** .

The goal of the vertical slice is  **not content quantity** , but to prove:

* The DNA system works end-to-end
* Monsters can be created, controlled, and automated
* Combat, farming, and AI integrate cleanly
* The architecture is scalable and moddable

The slice should be  **fun, stable, and expandable** .

---

## 2. Vertical Slice Definition

### What the slice MUST include

* One small world map
* One farm map
* 3–5 DNA parts per layer
* 3–4 monsters simultaneously
* Real-time combat
* Farm automation
* One defensive raid

### What it MUST prove

* DNA → Monster Assembly → Gameplay loop
* Player intent → AI behavior → Feedback
* Systems reuse (no one-off hacks)

---

## 3. Core Gameplay Loop (Slice)

```
Explore World
   ↓
Fight Monsters (Combat AI)
   ↓
Collect DNA
   ↓
Assemble Monster
   ↓
Deploy to Farm
   ↓
Farm Automation
   ↓
Raid Defense
   ↓
Repeat
```

If this loop works, the game works.

---

## 4. Build Order Overview (Critical)

1. Data & DNA Foundation
2. Monster Runtime Entity
3. Combat (Minimal but Real)
4. Player Control UX
5. Farm Automation
6. Raid / Defense Scenario
7. Editor Tooling (Minimum Viable)

Do **not** build systems out of order.

---

## 5. Phase 1 – Data & DNA Foundation (Week 1)

### Goals

* DNA system functional
* Monsters can be assembled deterministically

### Tasks

* Implement all DNA Resources
* Implement MonsterDNAStack
* Implement Validation Framework
* Implement Monster Assembly Pipeline
* CLI/editor test spawn

### Exit Criteria

* Monster can be spawned from DNA only
* Validation errors block bad builds

---

## 6. Phase 2 – Monster Runtime Entity (Week 2)

### Goals

* Monsters exist and persist in the world

### Tasks

* Create `monster_base.tscn`
* Implement core components:
  * HealthComponent
  * StressComponent
  * JobComponent
  * CombatComponent (stub)
* StatBlock system

### Exit Criteria

* Monsters move, idle, and persist
* Stats derived only from DNA

---

## 7. Phase 3 – Combat System (Week 3)

### Goals

* Real-time combat feels playable

### Tasks

* Implement Ability runtime objects
* Implement Targeting system
* Implement ThreatComponent
* Implement CombatAIComponent (basic scoring)
* Damage, cooldowns, death

### Exit Criteria

* Monsters fight autonomously
* Player can influence combat outcomes

---

## 8. Phase 4 – Player Control UX (Week 4)

### Goals

* RTS-style control works smoothly

### Tasks

* Selection & marquee
* Command issuing (attack, move, retreat)
* Ability UI (manual cast)
* Basic combat feedback

### Exit Criteria

* Player can control party confidently
* AI intent is readable

---

## 9. Phase 5 – Farm Automation (Week 5)

### Goals

* Farm runs itself

### Tasks

* FarmManager
* JobBoard
* Job scoring system
* Needs & stress loops
* Automation UI (rules, zones)

### Exit Criteria

* Monsters self-assign work
* Stress & happiness matter

---

## 10. Phase 6 – Raid & Defense (Week 6)

### Goals

* Tower-defense gameplay validated

### Tasks

* Raid event spawner
* Defense jobs
* Combat + automation integration
* Failure states

### Exit Criteria

* Farm can be attacked
* Monsters defend logically

---

## 11. Phase 7 – Minimal Editor Tooling (Week 7)

### Goals

* Prevent content pain

### Tasks

* DNA Inspector (basic)
* Monster Preview Tool
* Validation dock

### Exit Criteria

* Designers/modders can add DNA safely

---

## 12. Slice Scope Constraints (IMPORTANT)

### Explicitly OUT of scope

* Full progression trees
* Multiplayer
* Massive maps
* Dozens of abilities
* Complex UI polish

Resist scope creep.

---

## 13. Risk Management

| Risk           | Mitigation                |
| -------------- | ------------------------- |
| AI too complex | Start with few jobs/roles |
| Combat unclear | Heavy debug overlays      |
| DNA chaos      | Strict validation         |

---

## 14. Success Criteria

The slice is successful if:

* The core loop is fun for 15–30 minutes
* Systems feel reusable
* Adding content feels easy
* No major refactors required

---

## 15. Post-Slice Expansion Paths

After success:

* Add more DNA layers
* Add world biomes
* Add monster breeding
* Expand automation depth

---

## 16. Summary

This Vertical Slice plan:

* Is realistic for a small team or solo dev
* Proves the hardest systems first
* Prevents architectural debt
* Turns design into execution

If this slice works,  **the full game is inevitable** .
