# Godot 4 Monster DNA Farm RTS – Editor Tool Implementation Plan

---

## 1. Purpose of Editor Tools

Editor tools are a  **core production feature** , not a convenience.

Goals:

* Minimize iteration time
* Reduce human error
* Enable designers and modders to work without code
* Enforce validation early
* Make emergent systems *observable*

All tools are built using **Godot 4 EditorPlugin APIs** and shipped with the game (for mod support).

---

## 2. Tooling Philosophy

### 2.1 Data > Code

* Tools operate on Resources
* No gameplay logic in tools
* Tools visualize and validate data only

### 2.2 Fail Fast, Warn Smart

* Errors block saves/builds
* Warnings allow risky content
* Validation explains  *why* , not just *what*

### 2.3 One-Click Insight

* Designers should see outcomes instantly
* No hidden math

---

## 3. Core Editor Tools Overview

### Required Tools

1. DNA Resource Inspector (Custom)
2. DNA Stack Validator
3. Monster Preview Generator
4. Ability Preview Sandbox
5. Farm Simulation Test Mode
6. Automation Debug Overlay
7. Mod Validation Tool

Each tool is modular and independently extensible.

---

## 4. DNA Resource Inspector

### Purpose

Replace the default Resource inspector for DNA types with a  **layer-aware, validation-driven UI** .

### Features

* Collapsible DNA layers
* Tag & incompatibility visualization
* Live stat aggregation preview
* Color-coded validation messages

### Implementation

* EditorInspectorPlugin
* Per-DNA-type custom drawers
* Hooks into validation system

### Output

* Clean, readable DNA authoring
* Immediate feedback

---

## 5. DNA Stack Validator Tool

### Purpose

Validate a *complete monster build* across all DNA layers.

### Features

* Drag-and-drop DNA Resources
* Validation phases:
  * Structural
  * Tag conflicts
  * Slot limits
  * Instability thresholds
* Error / Warning / Info levels

### Implementation

* EditorPlugin + Dock
* Reuses runtime validation logic

### Output

* Prevents broken monsters from ever spawning

---

## 6. Monster Preview Generator

### Purpose

Instantly visualize a monster without entering the game.

### Features

* Assembles monster scene at editor-time
* Applies visuals from DNA
* Displays:
  * Final stats
  * Ability list
  * AI role summary
* Simple animation playback

### Implementation

* PackedScene instancing
* Offscreen SubViewport
* Read-only simulation context

### Output

* Faster iteration on look, feel, and balance

---

## 7. Ability Preview Sandbox

### Purpose

Test abilities in isolation.

### Features

* Spawn dummy targets
* Fire abilities manually
* Show cooldowns, AoE, damage numbers
* Toggle modifiers

### Implementation

* Minimal combat scene
* Ability execution hooks

### Output

* Ability tuning without full game boot

---

## 8. Farm Simulation Test Mode

### Purpose

Stress-test farm automation and raids.

### Features

* Run farm simulation at 1x–50x speed
* Inject raid events
* Pause, rewind, inspect state
* Job assignment heatmaps

### Implementation

* Separate test scene
* Time scaling
* Debug-only overlays

### Output

* Detects automation deadlocks and balance issues early

---

## 9. Automation Debug Overlay

### Purpose

Make monster decision-making visible.

### Features

* Display current job
* Show priority scores
* Highlight AI state
* Pathfinding visualization

### Implementation

* DebugDraw API
* Toggleable editor overlay

### Output

* AI behavior becomes understandable

---

## 10. Mod Validation Tool

### Purpose

Ensure mods are safe, compatible, and future-proof.

### Features

* Validate mod manifests
* Dependency resolution
* Resource schema checks
* Version compatibility warnings

### Implementation

* Editor dock
* Shared validation framework

### Output

* Reduces mod breakage and support burden

---

## 11. Shared Validation Framework

### Architecture

* ValidationRules as Resources
* Stateless validators
* Used by:
  * Editor tools
  * Runtime spawn checks
  * CI scripts

### Benefits

* Single source of truth
* No drift between editor and game

---

## 12. Automation & CI Integration

### Pre-Commit Checks

* Validate all Resources
* Fail build on critical errors

### Batch Tools

* Regenerate previews
* Rebuild caches

---

## 13. Modder-Facing Tooling

* All editor tools shipped with game
* Read-only mode for protected assets
* Documentation tooltips

This turns modding into  **first-class development** .

---

## 14. Implementation Order (Critical)

1. Validation Framework
2. DNA Inspector
3. DNA Stack Validator
4. Monster Preview Generator
5. Ability Sandbox
6. Automation Debug Overlay
7. Farm Simulation Test Mode
8. Mod Validation Tool

---

## 15. Success Metrics

Editor tools are successful if:

* Designers never need code for content
* Broken monsters never reach runtime
* Balance iteration is fast and confident
* Mods rarely break saves

---

## 16. Summary

These editor tools:

* Are essential infrastructure
* Enable large-scale content safely
* Reduce technical debt
* Make complex systems legible

Without these tools, the game will not scale.
With them, it becomes a  **platform** , not just a project.
