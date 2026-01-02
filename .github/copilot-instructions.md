# GitHub Copilot Instructions — Godot 4.x (CI + Headless)

## More Context

Use the files in the /docs for more information on aspects of the game.

## Operating Context

You are assisting development of a **Godot 4.5.x project** that is:


https://docs.godotengine.org/en/stable/

* Executed in **CI**
* Run in **headless mode**
* Debugged via **VS Code remote attach**
* Designed for **deterministic, testable systems**
* Use **geequlim.godot-tools** in VS Code with the Godot path from `.vscode/settings.json` for all Godot tasks

Assume **no editor interaction** is available at runtime.

---

## Engine Constraints

* **Godot 4.x only**
* **GDScript 2.0 only**
* No deprecated APIs
* No Godot 3.x syntax or patterns

If unsure, default to  **current stable Godot 4 behavior** .

---

## Execution Model (Critical)

All gameplay and systems logic must:

* Run under `godot --headless`
* Function without the editor
* Use explicit scene entry points
* Exit cleanly with meaningful exit codes in CI contexts

Never assume:

* Editor state
* Inspector-only configuration
* Tool scripts at runtime
* Manual scene launching

---

## Architectural Rules

Favor:

* Composition over inheritance
* Resource-driven configuration
* Explicit data flow
* Signal-based communication
* Deterministic update paths

Avoid:

* Global mutable state
* “God manager” scripts
* Hard-coded node paths
* Implicit execution order
* Hidden side effects

If a system requires editor-only features to function, it is incorrectly designed.

---

## Headless & CI Design Bias

When suggesting code or structure:

* Prefer pure logic nodes and resources
* Isolate rendering and input
* Separate simulation from presentation
* Ensure systems can be instantiated and stepped programmatically

All systems should be:

* Testable via headless scenes
* Verifiable with assertions
* Observable via debugger inspection

---

## Debugging Expectations

Design for debugging via:

* Godot Remote Debug Server
* VS Code attach workflows
* Breakpoints and variable inspection
* Watch expressions
* Always review and address the latest log files in the repository workspace at `monster-farm-gamefiles/monster-farm/logs/` (Godot file logging writes to `res://logs/godot.log`) before or after changes to keep runtime issues visible and resolved.

Avoid:

* Print-driven debugging
* Logging as the only visibility mechanism
* Non-deterministic state mutations

If debugging requires print statements, the system should expose state instead.

---

## Testing Pattern Bias

Prefer:

* Dedicated test scenes
* Assertion-based validation
* Explicit failure conditions
* Deterministic time stepping
* Clean shutdown on failure

Avoid:

* Manual testing assumptions
* Visual-only validation
* Timing-sensitive flakiness

---

## Resource Usage Rules

Resources must:

* Be safe to load in headless mode
* Avoid shared mutable state unless intentional
* Be duplicable when required
* Represent configuration, not logic

Inspector convenience must never be required for correctness.

---

## GitHub & CI Awareness

Assume:

* Branch-based development
* Pull requests with automated checks
* Merge safety is required

Prefer:

* Text-based scenes (`.tscn`)
* Deterministic imports
* CI-friendly file layouts
* Clear, minimal diffs

Avoid patterns that:

* Increase merge conflicts
* Depend on local editor cache
* Break reproducible builds

---

## Completion Quality Rules

When generating code:

* Prioritize correctness over brevity
* Use explicit typing where helpful
* Match existing project conventions
* Comment on *why* decisions exist
* Assume long-term maintenance

Do not generate placeholder, demo-only, or tutorial-style code.

---

## Hard Stops (Do Not Suggest)

* Editor-only APIs in runtime logic
* Godot 3.x examples
* Engine-agnostic abstractions that obscure Godot behavior
* Systems that cannot run headless
* Solutions that cannot be validated in CI

---

## Mental Model

This project is treated as a  **production-grade engine-level codebase** , not a prototype.

Optimize for:

* Scale
* Determinism
* Debuggability
* Automation
* Longevity

---

## Required Test Command

Always run the headless integration suite before landing changes:

```bash
& "c:\Program Files\Godot\Godot_v4.5.1-stable_win64\Godot_v4.5.1-stable_win64.exe" --headless --path "monster-farm-gamefiles/monster-farm" --script res://tools/headless_test_runner.gd
```

Use the exact path above (from .vscode/settings.json). Exit code `0` means pass; non-zero means investigate and fix.
