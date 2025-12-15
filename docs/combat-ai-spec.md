# Godot 4 Monster DNA Farm RTS – Combat AI Specification

---

## 1. Purpose

This document defines the **Combat AI system** used for real-time, party-based combat inspired by **StarCraft-style unit control** and  **WoW-like abilities** , while remaining fully data-driven and DNA-influenced.

Goals:

* Real-time, non–turn-based combat
* Player can issue high-level commands
* Monsters act autonomously within intent
* Scales from 1 monster to large parties
* Reuses systems across world combat, raids, and farm defense

---

## 2. Core Combat Philosophy

### 2.1 Player = Commander, Not Puppeteer

* Player issues *intent* (attack, defend, focus, retreat)
* Monsters decide *how* to execute

### 2.2 AI Is Advisory, Not Absolute

* AI suggests actions every tick window
* Player commands override scoring

### 2.3 Same AI Everywhere

* World exploration
* Dungeon encounters
* Farm defense (tower-defense raids)

No special-case combat logic.

---

## 3. High-Level Architecture

### Core Components

* CombatComponent
* AbilityComponent
* TargetingComponent
* CombatAIComponent
* ThreatComponent

Combat AI **never moves units directly** — it scores actions.

---

## 4. Combat States

Each monster operates in a  **Combat State** :

| State   | Description                |
| ------- | -------------------------- |
| Idle    | No threats                 |
| Engage  | Actively fighting          |
| Hold    | Defend area / position     |
| Retreat | Disengage and flee         |
| Berserk | Uncontrolled (instability) |

State influences action scoring weights.

---

## 5. Player Command Layer

Player issues commands to a  **selected group** :

### Command Types

* Attack Target
* Attack-Move
* Defend Area
* Hold Position
* Focus Fire
* Retreat

Commands:

* Set constraints
* Modify priorities
* Never directly fire abilities

---

## 6. Target Selection Logic

Targets are scored per monster.

### Target Score Inputs

```
TargetScore =
  ThreatValue
+ RolePreference
+ VulnerabilityScore
- DistancePenalty
- DangerPenalty
```

Examples:

* Tanks prefer high-threat targets
* Assassins prefer low-health targets
* Ranged units prefer safe distance

---

## 7. Ability Selection Logic

Each ability is scored independently.

### Ability Score Inputs

```
AbilityScore =
  BaseWeight
+ RoleSynergy
+ CooldownReadiness
+ TargetFit
- ResourceCostPenalty
```

Abilities may be:

* Offensive
* Defensive
* Utility

AI respects cooldowns and energy.

---

## 8. Role-Based Behavior

Roles derived from DNA + player override:

| Role       | Behavior                    |
| ---------- | --------------------------- |
| Tank       | Draw threat, protect allies |
| DPS        | Maximize damage             |
| Controller | Crowd control               |
| Support    | Buff/heal allies            |
| Skirmisher | Hit-and-run                 |

Roles adjust scoring weights only.

---

## 9. Threat & Aggro System

ThreatComponent tracks:

* Damage dealt
* Taunts
* Proximity

AI uses threat data for targeting and protection.

---

## 10. Group Coordination

Monsters share limited combat context:

* Current focus target
* Area danger zones
* Cooldown awareness

No hive-mind micromanagement.

---

## 11. Instability & Combat AI

High instability can:

* Override commands
* Trigger Berserk state
* Cause friendly fire
* Ignore retreat

This emerges naturally via scoring distortion.

---

## 12. Combat Tick Cycle

* Runs every 0.1–0.3 seconds
* Per monster:
  * Update combat state
  * Score targets
  * Score abilities
  * Select best action

Actions executed by components.

---

## 13. Debug & Visualization

Combat debug overlay shows:

* Current state
* Target scores
* Ability scores
* Threat values

Essential for tuning and trust.

---

## 14. Performance Considerations

* Stagger AI ticks
* Cache target lists
* Early exits for idle units

Designed for RTS-scale combat.

---

## 15. Emergent Combat Examples

* Supports auto-position near tanks
* Berserk monsters ignore retreat
* Squishy monsters kite naturally

No scripting required.

---

## 16. Summary

The Combat AI system:

* Is real-time and scalable
* Honors player intent without micromanagement
* Shares DNA-driven personality
* Works consistently across all combat modes

This completes the  **core gameplay AI triangle** :

* Combat AI
* Farm Automation AI
* Monster Assembly Pipeline

You now have a **complete systemic foundation** for the game.
