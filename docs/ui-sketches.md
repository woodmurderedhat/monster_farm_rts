# UI Sketches – Command Bar, Control Groups, Automation Debug

## Command Bar (Bottom HUD)
- Layout: left block for persistent commands (Attack-Move, Hold, Defend Area, Retreat); right block for ability slots (1–6) with cooldown rings.
- State: buttons show enabled/disabled (stamina/energy, cooldown), hover tooltip with cost, range, targeting mode.
- Input: left-click activates command or ability, right-click cancels targeting; number keys mirror ability slots; Ctrl+# saves control group, # recalls.
- Feedback: selection intent icons near monsters when a command is active; error toast for failure reasons (stress, needs, instability).

## Control Groups
- Indicator strip above command bar showing assigned groups (1–9) with small role icons; empty slots faded.
- Clicking a strip selects the group; double-click centers camera.
- Visual pulse on assigned monsters when a group is saved.

## Combat Debug Overlay (Slice)
- Floating text for abilities (blue) and damage (red) at target positions.
- Optional toggles: threat lines attacker→target, cooldown timers above monsters, status effect icons stacked near health bars.
- Lives as a CanvasLayer child; enable/disable via a debug toggle in settings or hotkey.

## Automation Debug Overlay
- Per-monster callout: current job name, top 3 job scores, dominant need driving the choice, stress state, lock-in timer.
- Zone visualization: tinted polygons for allowed/forbidden zones; outline when selected.
- Job board panel: sortable list by score with live updates; clicking highlights candidate monsters.

## Accessibility & Readability
- Colorblind-safe palette for overlays and command highlights.
- UI scale slider and font size adjustments for HUD elements.
- Clear legends for overlays (threat color, job score color, stress state).
