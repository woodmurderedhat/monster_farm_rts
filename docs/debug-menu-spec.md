# Debug Manager – Detailed Technical Explanation

## 1. What the Debug Manager *Is*

The **Debug Manager** is a **central, opt-in observability system** that:

* Visualizes *invisible gameplay logic* in real time
* Does **not** affect gameplay state
* Can be completely disabled at runtime (zero cost)
* Is usable by **developers, designers, and modders**

Think of it as:

> *A developer HUD that turns black-box AI and combat math into readable information.*

---

## 2. Core Design Principles

### 2.1 Read-Only, Never Authoritative

* Debug Manager **never modifies** game state
* It only **listens** to signals and polls data
* No game logic branches on debug state

This prevents Heisenbugs.

---

### 2.2 Centralized, Layered, Toggleable

* One manager
* Multiple overlay layers
* Each layer toggled independently

This avoids “debug spaghetti”.

---

### 2.3 Zero-Cost When Disabled

When debug is off:

* No drawing
* No polling
* No allocations

This is enforced structurally.

---

## 3. High-Level Architecture

```
DebugManager (AutoLoad Singleton)
 ├─ DebugConfig
 ├─ OverlayRouter
 ├─ EntityRegistry (weak refs)
 └─ CanvasLayer (only active if enabled)
     ├─ HealthOverlay
     ├─ ThreatOverlay
     ├─ AggroOverlay
     ├─ DamageTextOverlay
     ├─ CooldownOverlay
```

---

## 4. DebugManager Responsibilities

### 4.1 Global Enable / Disable

```gdscript
DebugManager.enabled = true
```

This single flag:

* Activates CanvasLayer
* Registers signal listeners
* Enables overlay updates

When `false`, nothing runs.

---

### 4.2 Overlay Toggle Control

Each overlay has a flag:

```gdscript
show_health
show_threat
show_aggro
show_damage
show_cooldowns
```

These are exposed via:

* Keyboard shortcuts
* Debug menu UI
* Console commands (optional)

---

### 4.3 Entity Registration

Entities opt-in:

```gdscript
DebugManager.register_entity(self)
```

Internally:

* Stored as **weak references**
* Automatically cleaned when entities free

This prevents memory leaks.

---

## 5. Debug Data Flow

### 5.1 Signal-Driven Where Possible

Entities emit signals:

```gdscript
signal damage_taken(amount, source)
signal threat_generated(amount, target)
signal ability_cast(ability)
```

Debug Manager listens  **only if enabled** .

---

### 5.2 Polling Only for Passive Data

Some values are polled:

* Current HP
* Cooldown remaining
* Active target

Polling happens **only** for visible entities and enabled overlays.

---

## 6. Overlay Implementations (Detailed)

---

### 6.1 Health Overlay

**Purpose**

* Verify stat math
* Confirm damage application

**Visual**

* Thin bar above unit
* Numeric HP optional

**Data Source**

* `StatComponent.current_hp`
* `StatComponent.max_hp`

**Update Strategy**

* Polled at low frequency (e.g. 10 Hz)

---

### 6.2 Threat Overlay (CRITICAL FOR YOUR GAME)

**Purpose**

* Make aggro logic visible
* Debug AI targeting

**Visual**

* Lines from attacker → target
* Thickness = threat value
* Color = faction

**Data Source**

* `ThreatComponent.threat_table`

```gdscript
Dictionary[target: Node] = threat_value
```

**Rendering Rule**

* Only top N threats drawn
* Lines fade over time

---

### 6.3 Aggro Overlay

**Purpose**

* Show current target selection

**Visual**

* Solid line to current target
* Target highlight ring

**Data Source**

* `CombatComponent.current_target`

This layer answers:

> *“Why is this monster attacking THAT?”*

---

### 6.4 Damage Number Overlay

**Purpose**

* Validate balance & scaling

**Visual**

* Floating text
* Color by damage type
* Crits scale size briefly

**Data Source**

* `damage_taken` signal

**Performance Rule**

* Pooled text nodes
* Max on screen at once

---

### 6.5 Cooldown Overlay

**Purpose**

* Debug ability pacing
* Identify AI stalling

**Visual**

* Radial or numeric timers near unit

**Data Source**

* `AbilityRuntime.cooldown_remaining`

**Update Strategy**

* Only when ability component exists

---

## 7. Rendering Strategy (Godot 4 Specific)

### 7.1 CanvasLayer Usage

* All debug visuals live in a dedicated `CanvasLayer`
* Z-index above gameplay, below UI
* Camera transforms accounted for

---

### 7.2 Draw vs Node Tradeoffs

| Overlay              | Method      |
| -------------------- | ----------- |
| Lines (threat/aggro) | `_draw()` |
| Bars/icons           | Nodes       |
| Text                 | Label nodes |

Minimize node count.

---

## 8. Input & UX

### Default Debug Keys (Example)

| Key | Toggle       |
| --- | ------------ |
| F1  | Debug master |
| F2  | Health       |
| F3  | Threat       |
| F4  | Aggro        |
| F5  | Damage       |
| F6  | Cooldowns    |

All configurable.

---

## 9. Modding Support

Mods can:

* Register custom overlays
* Emit debug signals
* Add new stat visualizers

They  **cannot** :

* Modify core overlays
* Override debug math

---

## 10. Safety Guarantees

The Debug Manager is guaranteed to:

* Never affect game outcome
* Never persist state
* Never crash gameplay if misconfigured
* Fail silently in release builds

---

## 11. Release Build Behavior

In release builds:

* DebugManager exists
* All overlays disabled
* No signals connected
* No overhead

You can also compile it out entirely if desired.

---

## 12. Why This System Is Non-Optional

Given your game:

* Autonomous AI
* RTS control
* DNA-driven stats
* Farm automation
* Emergent combat

**Without this system, balancing becomes guesswork.**

With it:

* You can *see* intent
* You can *trust* AI
* You can *scale* complexity safely

---
