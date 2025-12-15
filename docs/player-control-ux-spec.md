# Godot 4 Monster DNA Farm RTS – Player Control UX Specification

---

## 1. Purpose

This document defines the **Player Control UX** for commanding monsters in real time across  **world exploration** ,  **combat** , and  **farm defense** , blending:

* RTS-style selection & commands (StarCraft)
* RPG-style party management (WoW)
* Sim-style rule setting (RimWorld)

Goals:

* Minimal micromanagement
* Clear player intent
* High trust in AI decisions
* Scales from 1 to many monsters

---

## 2. Core UX Philosophy

### 2.1 Intent Over Execution

* Player expresses  *what they want* , not *how*
* AI decides execution details

### 2.2 Visibility = Trust

* Every AI decision must be inspectable
* Player should always know *why* something happened

### 2.3 One-Hand Friendly

* Mouse-first, keyboard optional
* All critical actions reachable quickly

---

## 3. Camera & World Interaction

### Camera

* Top-down or slight isometric
* Smooth pan (WASD or edge scroll)
* Zoom in/out (mouse wheel)

### World Interaction

* Left-click: select
* Right-click: context command
* Drag: marquee select

---

## 4. Selection System

### Selection Types

* Single monster
* Multi-selection (same or mixed types)
* Control groups (1–9)

### Selection Feedback

* Colored outlines per monster
* Role icons (Tank, DPS, Support)
* Health, stress, stamina bars

---

## 5. Command Model

Commands modify  **AI priorities** , not actions directly.

### Core Commands (Right-Click Contextual)

| Context   | Command             |
| --------- | ------------------- |
| Enemy     | Attack / Focus Fire |
| Ground    | Move / Attack-Move  |
| Structure | Defend / Use        |
| Safe Zone | Retreat             |

---

## 6. Command Bar (Bottom UI)

### Persistent Commands

* Attack-Move
* Hold Position
* Defend Area
* Retreat

### Conditional Commands

* Special formations
* Ability toggles

Commands apply to current selection.

---

## 7. Ability UX

### Passive vs Active

* Passive abilities auto-used by AI
* Active abilities:
  * Auto (AI-controlled)
  * Manual override (player-triggered)

### Manual Casting

* Click ability → target
* Cooldowns & costs clearly shown

---

## 8. Party & Formation Control

### Formations

* Line
* Wedge
* Spread
* Custom (DNA-influenced)

Formations affect:

* Threat distribution
* AoE vulnerability

---

## 9. Combat Feedback

### Visual Feedback

* Damage numbers
* Status effect icons
* Target markers

### Intent Feedback

* Icons showing current AI goal
* Ability intent previews

---

## 10. Farm Automation UX

### Monster Rules Panel

Per-monster or group:

* Allowed jobs
* Job priority sliders
* Combat participation toggle
* Zone restrictions

### Zones

* Draw zones directly on map
* Assign rules per zone

---

## 11. DNA & Role Overrides

Player may:

* Lock combat role
* Set preferred abilities
* Allow/disallow instability behavior

Overrides bias AI scoring, never hard-lock behavior.

---

## 12. Failure Transparency

When monsters disobey:

* UI explains why (stress, fear, instability)
* Suggestions shown to fix issue

Failure feels fair, not random.

---

## 13. Debug & Advanced Controls

Optional overlays:

* AI intent arrows
* Threat heatmap
* Job scoring numbers

Targeted at advanced players and modders.

---

## 14. Accessibility & Customization

* Fully rebindable controls
* Colorblind-safe indicators
* Adjustable UI scale

---

## 15. Mode Consistency

The same control model works in:

* Exploration
* Dungeons
* Farm defense

UI adapts contextually but never changes rules.

---

## 16. Example Player Flow

1. Player explores world with party
2. Encounters enemies
3. Drag-select party
4. Attack-move into area
5. Monsters auto-engage
6. Player manually triggers clutch ability
7. Retreat when stress spikes

Zero micromanagement required.

---

## 17. Summary

The Player Control UX:

* Makes complex AI approachable
* Rewards planning over clicks
* Scales with player skill
* Reinforces the fantasy of commanding living creatures

This UX completes the **player-facing layer** of the engine.
