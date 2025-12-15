# Selection Manager - Handles RTS-style unit selection
# Supports click selection, shift-click multi-select, and marquee box selection
extends Node
class_name SelectionManager

## Currently selected monsters
var selected_monsters: Array[Node2D] = []

## Whether we're currently drawing a selection box
var is_drawing_box: bool = false

## Selection box start position (screen space)
var box_start: Vector2 = Vector2.ZERO

## Selection box end position (screen space)
var box_end: Vector2 = Vector2.ZERO

## Reference to the camera
var camera: Camera2D

## Reference to the selection box visual
var selection_box_visual: Control


func _ready() -> void:
	# Find camera in scene
	await get_tree().process_frame
	camera = get_viewport().get_camera_2d()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion and is_drawing_box:
		_handle_mouse_motion(event as InputEventMouseMotion)


## Handle mouse button events
func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_selection(event.position)
		else:
			_end_selection(event.position, event.shift_pressed)
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_issue_command(event.position)


## Start selection (click or box)
func _start_selection(screen_pos: Vector2) -> void:
	box_start = screen_pos
	box_end = screen_pos
	is_drawing_box = true
	
	if selection_box_visual:
		selection_box_visual.visible = true


## End selection
func _end_selection(screen_pos: Vector2, add_to_selection: bool) -> void:
	box_end = screen_pos
	is_drawing_box = false
	
	if selection_box_visual:
		selection_box_visual.visible = false
	
	var box_size := (box_end - box_start).abs()
	
	if box_size.length() < 10:
		# Click selection
		_click_select(_screen_to_world(screen_pos), add_to_selection)
	else:
		# Box selection
		_box_select(add_to_selection)


## Handle mouse motion for box drawing
func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	box_end = event.position
	_update_selection_box_visual()


## Click select at world position
func _click_select(world_pos: Vector2, add_to_selection: bool) -> void:
	var clicked_monster := _get_monster_at_position(world_pos)
	
	if not add_to_selection:
		_clear_selection()
	
	if clicked_monster:
		_add_to_selection(clicked_monster)


## Box select all monsters in the selection rectangle
func _box_select(add_to_selection: bool) -> void:
	if not add_to_selection:
		_clear_selection()
	
	var world_rect := _get_world_selection_rect()
	var monsters := _get_monsters_in_rect(world_rect)
	
	for monster in monsters:
		_add_to_selection(monster)
	
	EventBus.selection_box_drawn.emit(world_rect)


## Add a monster to selection
func _add_to_selection(monster: Node2D) -> void:
	if monster in selected_monsters:
		return
	
	selected_monsters.append(monster)
	
	if monster.has_method("select"):
		monster.select()
	
	EventBus.monster_selected.emit(monster)


## Remove a monster from selection
func _remove_from_selection(monster: Node2D) -> void:
	selected_monsters.erase(monster)
	
	if monster.has_method("deselect"):
		monster.deselect()
	
	EventBus.monster_deselected.emit(monster)


## Clear all selection
func _clear_selection() -> void:
	for monster in selected_monsters:
		if is_instance_valid(monster) and monster.has_method("deselect"):
			monster.deselect()
	
	selected_monsters.clear()
	EventBus.selection_cleared.emit()


## Issue command to selected monsters
func _issue_command(screen_pos: Vector2) -> void:
	var world_pos := _screen_to_world(screen_pos)
	var target := _get_monster_at_position(world_pos)
	
	if target and target not in selected_monsters:
		# Attack command
		for monster in selected_monsters:
			if monster.has_method("command_attack"):
				monster.command_attack(target)
		EventBus.player_command.emit("attack", {"target": target})
	else:
		# Move command
		for monster in selected_monsters:
			if monster.has_method("command_move"):
				monster.command_move(world_pos)
		EventBus.player_command.emit("move", {"position": world_pos})


## Convert screen position to world position
func _screen_to_world(screen_pos: Vector2) -> Vector2:
	if camera:
		return camera.get_global_mouse_position()
	return screen_pos


## Get world-space selection rectangle
func _get_world_selection_rect() -> Rect2:
	var start_world := _screen_to_world(box_start)
	var end_world := _screen_to_world(box_end)

	var min_pos := Vector2(minf(start_world.x, end_world.x), minf(start_world.y, end_world.y))
	var max_pos := Vector2(maxf(start_world.x, end_world.x), maxf(start_world.y, end_world.y))

	return Rect2(min_pos, max_pos - min_pos)


## Get monster at world position (uses physics query)
func _get_monster_at_position(world_pos: Vector2) -> Node2D:
	var space_state := get_viewport().get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collision_mask = 2  # Monster collision layer
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var results := space_state.intersect_point(query, 1)

	if results.size() > 0:
		var collider: Node2D = results[0].collider
		if collider is Monster:
			return collider
		# Check parent in case we hit a child collider
		if collider.get_parent() is Monster:
			return collider.get_parent()

	return null


## Get all monsters in a world-space rectangle
func _get_monsters_in_rect(rect: Rect2) -> Array[Node2D]:
	var monsters: Array[Node2D] = []

	var space_state := get_viewport().get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()

	var shape := RectangleShape2D.new()
	shape.size = rect.size
	query.shape = shape
	query.transform = Transform2D(0, rect.position + rect.size / 2)
	query.collision_mask = 2  # Monster collision layer

	var results := space_state.intersect_shape(query, 32)

	for result in results:
		var collider: Node2D = result.collider
		if collider is Monster and collider not in monsters:
			monsters.append(collider)
		elif collider.get_parent() is Monster and collider.get_parent() not in monsters:
			monsters.append(collider.get_parent())

	return monsters


## Update the selection box visual
func _update_selection_box_visual() -> void:
	if selection_box_visual and selection_box_visual.has_method("set_box"):
		selection_box_visual.set_box(box_start, box_end)

