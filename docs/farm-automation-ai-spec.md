# Godot 4 Monster DNA Farm RTS – Farm Automation AI Specification

---

## 1. Purpose

This document defines the **Farm Automation AI system** responsible for assigning jobs, managing monster behavior, and maintaining farm productivity and happiness.

Goals:

* Fully automated farms with minimal micromanagement
* Emergent behavior driven by DNA, needs, and environment
* Deterministic, debuggable decision-making
* Scales from 5 monsters to hundreds

This system is inspired by *Dwarf Fortress* and  *RimWorld* , but adapted to  **real-time action** ,  **monster personalities** , and  **Godot 4 performance constraints** .

---

## 2. Core Design Principles

### 2.1 Priority-Based AI, Not Scripts

* No hardcoded behavior trees per monster
* Decisions are scored every tick window
* Highest score wins

### 2.2 Data-Driven Jobs

* Jobs are Resources
* Monsters evaluate jobs, not the other way around

### 2.3 Soft Autonomy

* Player gives  *rules and zones* , not orders
* Monsters interpret intent via DNA and needs

---

## 3. High-Level Architecture

### Core Systems

* FarmManager
* JobBoard
* JobComponent (per monster)
* NeedsComponent
* Stress/Happiness System
* AI Scoring System

No system directly controls movement or actions — they  **suggest priorities** .

---

## 4. Monster Needs Model

Each monster has continuous needs:

| Need    | Description             |
| ------- | ----------------------- |
| Hunger  | Requires feeding        |
| Rest    | Requires idle/sleep     |
| Safety  | Avoid threats           |
| Social  | Interaction with others |
| Purpose | Doing preferred work    |

Needs decay or grow over time and influence job scoring.

---

## 5. Job Definition

### JobResource

```gdscript
extends Resource
class_name JobResource

@export var job_id: String
@export var display_name: String
@export var base_priority: float = 1.0
@export var required_tags: Array[String] = []
@export var forbidden_tags: Array[String] = []
@export var work_type: String
@export var danger_level: float = 0.0
```

Examples:

* Feed Livestock
* Patrol Perimeter
* Train Combat
* Repair Structures
* Rest

---

## 6. Job Scoring Formula

Each monster evaluates all available jobs periodically.

### Score Components

```
FinalScore =
  BasePriority
+ DNAAffinity
+ NeedUrgency
+ SkillModifier
- StressPenalty
- DangerPenalty
```

### Key Inputs

* **DNAAffinity** : from DNABehavior.work_affinity
* **NeedUrgency** : unmet needs boost relevant jobs
* **StressPenalty** : stressed monsters avoid work
* **DangerPenalty** : low courage monsters avoid danger

---

## 7. Decision Cycle

* Runs every X seconds (configurable)
* Monsters re-evaluate jobs
* Job with highest score is selected
* Lock-in period prevents thrashing

This keeps behavior stable but reactive.

---

## 8. Zones & Player Rules

Players influence automation through:

* Allowed zones
* Forbidden zones
* Job priority sliders
* Monster role assignment

Rules modify job availability and scoring, not commands.

---

## 9. Stress & Happiness System

Stress increases from:

* Overwork
* Combat
* Hunger
* Poor environment

Happiness increases from:

* Preferred work
* Social interaction
* Comfort structures

Effects:

* High stress lowers job efficiency
* Extreme stress causes refusal, berserk, or escape

---

## 10. Farm Defense Integration

During raids:

* New Defense jobs injected
* Combat-capable monsters reprioritize
* Civilians seek safety jobs

This uses the  **same job system** , not special logic.

---

## 11. Automation Debugging

Debug overlays show:

* Current job
* Job scores
* Need levels
* Stress state

Essential for tuning and player trust.

---

## 12. Performance Considerations

* Jobs cached per farm
* Monsters evaluate in staggered ticks
* Scoring math kept simple

Designed to handle large farms.

---

## 13. Emergent Behavior Examples

* Aggressive monsters patrol naturally
* Lazy monsters gravitate to rest
* Overworked farms collapse organically

No scripts required.

---

## 14. Failure Modes (Intentional)

* Monsters refuse tasks
* Work slows
* Mutations triggered by stress

Failure is gameplay, not a bug.

---

## 15. Summary

The Farm Automation AI:

* Is systemic, not scripted
* Driven by DNA, needs, and environment
* Scales cleanly
* Powers defense, production, and personality

This system turns your farm into a  **living ecosystem** , not a checklist.
