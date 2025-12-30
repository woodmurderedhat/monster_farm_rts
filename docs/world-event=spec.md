# Godot 4 Monster DNA Farm RTS – World Event System Specification

---

## 1. Purpose

This document defines the  **World Event System** , which governs dynamic, systemic events that affect:

* The Overworld (biomes & regions)
* The Player Farm
* Dungeons (indirectly, via modifiers and availability)

World Events are designed to:

* Create pressure and urgency
* Tie player success to escalating consequences
* Make the world feel alive and reactive

Events are  **system-driven** , not scripted set pieces.

---

## 2. Core Design Pillars

### 2.1 Events Are Consequences

Events primarily arise from:

* Player over-harvesting
* Ignored threats
* Regional instability

Not from random rolls alone.

---

### 2.2 Events Are Multi-Scope

An event may:

* Start in one biome
* Propagate to others
* Escalate into farm raids
* Modify dungeon rules

No event exists in isolation.

---

### 2.3 Events Modify Systems, Not Rules

Events apply:

* Stat modifiers
* Spawn weight shifts
* AI behavior biases

They do **not** introduce bespoke logic.

---

## 3. World Event Lifecycle

```
Trigger → Incubation → Active → Resolution → Fallout
```

Each phase is visible to the player.

---

## 4. WorldEventResource Schema

```gdscript
extends Resource
class_name WorldEventResource

@export var event_id: String
@export var display_name: String
@export var description: String

@export var trigger_conditions: Array[EventTrigger]
@export var duration: float

@export var region_modifiers: Array[EnvironmentModifierProfile]
@export var spawn_overrides: BiomeSpawnProfile

@export var escalation_profile: EventEscalationProfile
@export var resolution_profile: EventResolutionProfile
```

---

## 5. Event Trigger System

### 5.1 Trigger Types

Events can trigger from:

* Time thresholds
* Player actions (kills, farming rate)
* World state values (population density)

---

### 5.2 EventTrigger Resource

```gdscript
extends Resource
class_name EventTrigger

@export var trigger_type: String
@export var threshold: float
@export var comparison: String # > < ==
```

Multiple triggers may be required.

---

## 6. Incubation Phase

### Purpose

* Warn the player
* Allow preparation

### Signals

* UI notifications
* Environmental VFX
* NPC dialogue

Incubation duration is configurable.

---

## 7. Active Phase Effects

### 7.1 Regional Modifiers

Examples:

* Increased aggression
* Faster monster reproduction
* Elemental instability

Applied via EnvironmentModifierProfile.

---

### 7.2 Spawn Overrides

* Increased elite chance
* New mutation pools
* Apex monster appearances

Spawn logic remains biome-driven.

---

## 8. Escalation System

### 8.1 EventEscalationProfile

```gdscript
extends Resource
class_name EventEscalationProfile

@export var escalation_rate: float
@export var escalation_events: Array[WorldEventResource]
```

If ignored, events can chain.

---

### 8.2 Farm Raid Escalation

Certain escalation paths:

* Spawn raid events
* Increase raid frequency
* Add special attackers

Raids are events, not separate systems.

---

## 9. Resolution System

### 9.1 Resolution Types

* Player intervention (kill target)
* Time decay
* Event superseded by escalation

---

### 9.2 EventResolutionProfile

```gdscript
extends Resource
class_name EventResolutionProfile

@export var resolution_type: String
@export var success_modifiers: Array[EnvironmentModifierProfile]
@export var failure_modifiers: Array[EnvironmentModifierProfile]
```

Resolution affects future world state.

---

## 10. Fallout & Persistence

After resolution:

* World state values update
* Biome difficulty may permanently shift
* New events unlocked

Nothing fully resets.

---

## 11. Player Visibility & UX

Players can see:

* Active events per region
* Escalation risk
* Potential outcomes

Uncertainty is allowed, opacity is not.

---

## 12. Godot 4 Runtime Architecture

### Managers

```
WorldEventManager (AutoLoad)
 ├─ EventScheduler
 ├─ EventTracker
 ├─ RegionBindings
```

---

### Data Flow

```
World State → Trigger Check → Event Spawn → Apply Modifiers
```

No per-frame heavy logic.

---

## 13. Modding Support

Mods can:

* Add new events
* Add triggers
* Add escalation chains

Validation ensures no infinite loops.

---

## 14. Vertical Slice Events

Minimum slice:

* 1 regional instability event
* 1 migration event
* 1 farm raid escalation

---

## 15. Common Failure Points

Avoid:

* Pure RNG events
* Events without player agency
* Scripted-only sequences

---

## 16. Summary

The World Event System:

* Connects overworld, farm, and dungeons
* Turns player success into new challenges
* Keeps the world reactive and alive
* Scales indefinitely via data

Events are the **heartbeat** of the world.
