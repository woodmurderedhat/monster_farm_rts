# Godot 4 Monster DNA Farm RTS – Narrative Event Layer Specification

---

## 1. Purpose

This document defines the  **Narrative Event Layer** , a lightweight storytelling system that **rides on top of** the World Event System without breaking systemic gameplay.

Goals:

* Deliver narrative meaning without cutscenes
* Preserve player agency and automation
* Scale infinitely with minimal authoring cost
* Never override or contradict mechanics

Narrative is  **emergent, reactive, and optional** .

---

## 2. Core Narrative Philosophy

### 2.1 Systems First, Story Second

* Narrative events *explain* systems
* They never change rules or outcomes
* Gameplay always resolves first

Narrative answers  **why** , never  **what** .

---

### 2.2 Environmental & Diegetic Delivery

Narrative is delivered through:

* Event notifications
* NPC messages
* Environmental changes
* Codex entries

No hard pauses. No loss of control.

---

### 2.3 Modular & Non-Linear

* No main quest dependency
* No fixed order
* Events unlock story fragments organically

The story assembles itself like DNA.

---

## 3. Narrative Event Types

### 3.1 World Commentary Events

Reactive narration tied to World Events.

Examples:

* Migration warnings
* Ecological collapse notices
* Rumors of apex monsters

These fire during **Incubation** and **Active** phases.

---

### 3.2 Character Perspective Events

Messages from NPCs, rivals, or factions.

Examples:

* Rival breeder taunts
* Researcher warnings
* Trader gossip

NPCs react to the same world state.

---

### 3.3 Discovery Events

Triggered by:

* New DNA combinations
* Rare mutations
* First dungeon clears

These reward curiosity, not progression.

---

### 3.4 Reflective Farm Events

Narrative moments triggered at the farm.

Examples:

* Monster unrest
* Overcrowding consequences
* Signs of prosperity

These humanize automation outcomes.

---

## 4. NarrativeEventResource Schema

```gdscript
extends Resource
class_name NarrativeEventResource

@export var narrative_id: String
@export var title: String
@export var text: String

@export var linked_world_event: WorldEventResource
@export var trigger_phase: String # incubation, active, resolution, fallout

@export var delivery_method: String # popup, log, npc, environment
@export var priority: int

@export var one_time: bool = true
```

---

## 5. Triggering Rules

Narrative events trigger when:

* Linked WorldEvent enters a phase
* Player discovers qualifying condition
* Farm state crosses a threshold

Narrative events  **never block gameplay** .

---

## 6. Delivery Channels

### 6.1 Event Feed

* Non-intrusive text feed
* Timestamped
* Filterable by category

---

### 6.2 Optional Popups

* Used sparingly
* Dismissible
* Never stacked

---

### 6.3 Environmental Storytelling

Examples:

* Corrupted terrain visuals
* Damaged farm structures
* NPC behavior changes

Driven by existing systems.

---

### 6.4 Codex / Archive

* Stores unlocked narrative fragments
* Organized by theme
* Optional reading

Completion is not required.

---

## 7. Narrative Consistency Rules

* No prophecy or guaranteed outcomes
* No player identity assumptions
* No moral enforcement

The world reacts; it does not judge.

---

## 8. Godot 4 Runtime Architecture

### Managers

```
NarrativeManager (AutoLoad)
 ├─ NarrativeScheduler
 ├─ DeliveryRouter
 ├─ NarrativeLog
```

---

### Data Flow

```
World Event → Narrative Trigger → Delivery Channel → Log
```

NarrativeManager subscribes to WorldEventManager signals.

---

## 9. Modding Support

Mods can:

* Add narrative events
* Add new delivery text
* Add codex entries

Mods cannot:

* Override outcomes
* Force events

---

## 10. Vertical Slice Narrative Scope

For the slice:

* 3 world commentary events
* 1 discovery event
* 1 farm reflection event

All optional.

---

## 11. Common Failure Points

Avoid:

* Long dialogue trees
* Mandatory story gates
* Lore dumps unrelated to systems

---

## 12. Summary

The Narrative Event Layer:

* Gives meaning to systemic play
* Preserves player agency
* Scales infinitely
* Respects automation and RTS pacing

Narrative becomes a  **shadow cast by systems** , not a script imposed on them.
