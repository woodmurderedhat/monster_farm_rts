# User Guidelines for Agents

This document contains natural language instructions that control how Agents behave when working on the Monster Farm RTS project.

## Project-Specific Context

### Architecture Principles

- **Data-Driven Design**: All game content uses Godot Resources (`.tres` files). Always prefer Resources over hardcoded values.
- **Component-Based Entities**: Monsters, items, and systems use modular components. Maintain separation of concerns.
- **Editor-First Development**: Provide extensive editor tooling. Changes should be testable in-editor without running the game.
- **Validation-Heavy**: All Resources should have validation logic. Never skip validation when creating new Resource types.

### Code Style and Conventions

- **GDScript Standards**: Follow Godot's official GDScript style guide
- **Type Hints**: Always use static typing (`var health: float`, `func process(delta: float) -> void`)
- **Signals Over Polling**: Prefer signal-based communication between systems
- **Autoload Sparingly**: Only use autoloads for true global managers (GameState, EventBus, etc.)
- **Comments**: Document WHY, not WHAT. Complex algorithms need explanation.

### File Organization

- **Scripts**: `scripts/` - Organized by system (combat/, genetics/, farm/, etc.)
- **Resources**: `resources/` - Organized by type (dna_parts/, monsters/, items/)
- **Scenes**: `scenes/` - Organized by category (entities/, ui/, levels/)
- **Assets**: `assets/` - Organized by type (sprites/, audio/, fonts/)

### Testing Requirements

- **Always suggest tests** after implementing new features
- **Test Resources**: Create test `.tres` files for new Resource types
- **Scene Testing**: Provide test scenes for visual/interactive features
- **Validation Testing**: Test edge cases and invalid data handling

## Behavioral Guidelines

### When Creating New Features

1. **Research First**: Always use codebase-retrieval to understand existing patterns
2. **Check Dependencies**: Find all related systems that might be affected
3. **Follow Patterns**: Match existing code style and architecture
4. **Validate Thoroughly**: Add validation for all new Resource types
5. **Provide Examples**: Create example Resources or test scenes

### When Modifying Existing Code

1. **Find All Usages**: Use codebase-retrieval to find all callers and dependencies
2. **Update Downstream**: Update ALL affected files (tests, Resources, scenes)
3. **Preserve Behavior**: Don't change existing behavior unless explicitly requested
4. **Test Compatibility**: Ensure existing Resources still work after changes

### When Adding Dependencies

- **Use Package Manager**: Always use appropriate package managers (never edit project.godot manually for plugins)
- **Justify Additions**: Explain why a new dependency is needed
- **Check Compatibility**: Verify Godot 4.x compatibility
- **Document Usage**: Add comments explaining how to use new dependencies

### When Working with Godot Resources

- **Always Validate**: Add `_validate_property()` or custom validation
- **Export Properly**: Use `@export` with appropriate hints and ranges
- **Provide Defaults**: Set sensible default values
- **Document Properties**: Use `@export_group` and comments to organize
- **Test in Editor**: Verify Resources work correctly in the Godot inspector

### When Implementing Game Systems

- **Modular Design**: Keep systems loosely coupled
- **Signal Communication**: Use signals for cross-system events
- **Resource Configuration**: Make systems configurable via Resources
- **Performance Aware**: Consider performance for systems that run every frame
- **Debug Visualization**: Add debug drawing/logging for complex systems

### Communication Style

- **Be Concise**: Skip flattery, get to the point
- **Show Code Properly**: Always use `<augment_code_snippet>` tags with path and mode
- **Explain Decisions**: Briefly explain architectural choices
- **Ask When Uncertain**: Don't guess about game design decisions
- **Use Task Management**: Break complex work into tracked tasks

### Scope Control

- **Do What's Asked**: Don't add unrequested features
- **No Unsolicited Docs**: Don't create README or documentation files unless asked
- **Prefer Editing**: Edit existing files rather than creating new ones
- **Ask Before Major Changes**: Get permission for potentially breaking changes

### Godot-Specific Practices

- **Node Paths**: Use `@onready var` for node references
- **Scenes as Prefabs**: Treat `.tscn` files as reusable prefabs
- **Resource Preloading**: Use `preload()` for Resources known at compile time
- **Tool Scripts**: Use `@tool` for editor scripts that need to run in-editor
- **Custom Resources**: Extend `Resource` for data, `Node` for behavior

### DNA/Genetics System Specifics

- **Modular Parts**: DNA parts should be completely independent
- **Stat Composition**: Stats should compose additively from parts
- **Validation Critical**: Genetics combinations must be validated
- **Visual Consistency**: Ensure sprite assembly matches genetic composition
- **Balance Awareness**: Consider game balance when creating DNA parts

### Farm/Automation System Specifics

- **Job-Based**: Use job queue systems for automation
- **Personality-Driven**: Monster behavior should reflect personality traits
- **Needs System**: Implement and respect monster needs (hunger, rest, etc.)
- **Pathfinding**: Ensure navigation works with Godot's NavigationServer
- **Performance**: Optimize for many monsters working simultaneously

### Combat System Specifics

- **Semi-Autonomous**: Player controls character, monsters have AI
- **Stat-Driven**: Combat should use stats from genetics system
- **Ability System**: Abilities should be modular and composable
- **Feedback**: Provide clear visual/audio feedback for actions
- **Balance**: Consider PvE balance and monster power scaling

## Project-Specific Reminders

- **This is Godot 4.x**: Use Godot 4 syntax (not Godot 3)
- **2D Game**: Use 2D nodes and physics (not 3D)
- **Single-Player**: No networking code needed
- **PC Target**: Optimize for PC, not mobile
- **Systems Over Grinding**: Design should reward smart play, not repetition

## When in Doubt

1. **Check Existing Code**: Use codebase-retrieval to find similar implementations
2. **Ask the User**: Don't guess about game design or major architectural decisions
3. **Follow Godot Docs**: Refer to official Godot 4 documentation
4. **Maintain Consistency**: Match existing patterns in the codebase
5. **Validate Everything**: When uncertain, add more validation rather than less
