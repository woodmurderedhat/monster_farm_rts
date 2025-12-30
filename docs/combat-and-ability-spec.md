# Godot 4 Monster DNA Farm RTS – Combat & Ability Systems Technical Specification

---

## 1. Purpose

This document consolidates **runtime combat systems** into a single, cohesive technical reference.

It defines:

* Ability Runtime System (GDScript)
* Stat & Modifier Math Model
* Combat Debug Overlay
* Monster Visual Node implementation

The goal is **deterministic, debuggable, and extensible combat** that cleanly integrates DNA, AI, UX, and VFX.

---

## 2. Ability Runtime System

### 2.1 Design Goals

* Abilities are data-driven
* Execution is deterministic
* Cooldowns and targeting are explicit
* AI and player use the same pipeline

No special-case code paths.

---

### 2.2 Ability Lifecycle

```
Request → Validate → Target → Execute → Resolve → Cooldown
```

Every ability follows this lifecycle.

---

### 2.3 Core Ability Classes

```gdscript
# ability_resource.gd
extends Resource
class_name AbilityResource

@export var id: String
@export var cooldown: float
@export var cast_time: float
@export var range: float
@export var targeting_mode: TargetingMode
@export var power_scalars: Dictionary
@export var vfx: AbilityVFXResource
```

```gdscript
# ability_runtime.gd
class_name AbilityRuntime

var owner
var resource: AbilityResource
var cooldown_remaining := 0.0

func can_cast() -> bool:
    return cooldown_remaining <= 0.0
```

---

### 2.4 Targeting System

#### Targeting Modes

* Self
* Unit
* Area
* Cone
* Line

Targeting produces a **TargetContext** object.

```gdscript
class TargetContext:
    var targets: Array
    var point: Vector2
```

---

### 2.5 Execution Hooks

Execution is broken into hooks:

```gdscript
pre_cast()
apply_costs()
apply_effects()
spawn_vfx()
post_cast()
```

Hooks allow:

* AI overrides
* Mod hooks
* Debug inspection

---

### 2.6 Cooldown Handling

* Cooldowns tick in `_process`
* Modified by stats (haste)
* Pausing supported

Cooldown math:

```
final_cooldown = base * (1 - haste)
```

---

## 3. Stat & Modifier Math Specification

### 3.1 Stat Categories

* Base Stats (DNA)
* Derived Stats
* Temporary Modifiers
* Status Effects

---

### 3.2 DNA Contribution Model

Each DNA layer contributes:

```
Base + Additive + Multiplicative
```

Order of operations:

1. Sum Base
2. Apply Additives
3. Apply Multipliers

---

### 3.3 Modifier Types

| Type         | Example     |
| ------------ | ----------- |
| Flat         | +10 HP      |
| Percent Add  | +15% Damage |
| Percent Mult | x1.2 Speed  |

Percent Add stacks additively, Mult stacks multiplicatively.

---

### 3.4 Final Stat Formula

```
Final = (Base + ΣFlat) * (1 + ΣPercentAdd) * ΠPercentMult
```

This formula is universal.

---

### 3.5 Ability Scaling

Abilities reference stats symbolically:

```
Damage = Power * STR * ElementMultiplier
```

No hardcoded numbers in code.

---

## 4. Combat Debug Overlay Specification

### 4.1 Goals

* Make AI decisions visible
* Debug combat balance
* Support tuning & modding

---

### 4.2 Overlay Elements

Toggleable layers:

* Health bars
* Threat meters
* Aggro lines
* Damage numbers
* Cooldown timers

---

### 4.3 Threat Visualization

* Lines from attacker → target
* Thickness = threat value
* Color-coded by faction

---

### 4.4 Damage Numbers

* Floating text
* Color by damage type
* Crits emphasized

---

### 4.5 Implementation

* CanvasLayer overlay
* Controlled by DebugManager
* Zero cost when disabled

---

## 5. Monster Visual Node Implementation

### 5.1 Node Hierarchy

```
Monster (CharacterBody2D)
 ├─ MonsterVisual (Node2D)
 │   ├─ BodySprite
 │   ├─ OverlayLayer
 │   ├─ MutationLayer
 │   ├─ StatusEffectLayer
 │   └─ AbilityVFXLayer
 ├─ AbilityComponent
 ├─ CombatComponent
 ├─ StatComponent
```

---

### 5.2 Visual Sync Rules

* Visuals never compute logic
* Logic emits signals
* Visual listens and reacts

Examples:

* `on_damage_taken`
* `on_status_applied`
* `on_ability_cast`

---

### 5.3 Animation Integration

* AnimationTree for base body
* Additive overlays for mutations
* Ability casts trigger animation states

---

### 5.4 VFX Integration

* Ability spawns VFX via resource
* VFX attaches to AbilityVFXLayer
* Cleanup handled automatically

---

## 6. System Guarantees

This architecture guarantees:

* Deterministic combat math
* Clear debugging
* AI/player parity
* Safe mod extension

---

## 7. Vertical Slice Requirements

Minimum implementation:

* 2 stats (HP, Damage)
* 2 abilities
* Debug overlay toggles
* One full ability lifecycle

---

## 8. Common Pitfalls (Avoid)

* Logic inside visuals
* Hidden stat modifiers
* Ability-specific math
* Non-universal formulas

---

## 9. Summary

This unified combat spec:

* Turns design into code-ready systems
* Prevents balance chaos
* Makes combat transparent
* Scales with content growth

This is the **combat spine** of the entire game.
