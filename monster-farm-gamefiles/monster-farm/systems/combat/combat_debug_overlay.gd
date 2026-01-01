@tool
# Combat Debug Overlay - lightweight visualizer for abilities and damage
# Attach as a child of the world root to visualize combat events
extends Node2D
class_name CombatDebugOverlay

@export var enabled: bool = true
@export var text_ttl: float = 1.2
@export var rise_speed: float = 35.0
@export var threat_ttl: float = 0.6
@export var toggle_action: String = "toggle_combat_debug"
@export var threat_toggle_action: String = "toggle_threat_lines"
@export var show_threat_lines: bool = true
@export var health_bar_width: float = 52.0
@export var health_bar_height: float = 5.0
@export var status_icon_size: float = 6.0

var _floaters: Array = []  # {text, color, ttl, pos}
var _threat_lines: Array = []  # {a:Vector2, b:Vector2, ttl:float, color:Color}
var _tracked_units: Array[Node2D] = []
var _cooldowns: Array = []  # {unit:Node2D, remaining:float, total:float}

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if EventBus.damage_dealt.is_connected(_on_damage_dealt) == false:
		EventBus.damage_dealt.connect(_on_damage_dealt)
	if EventBus.ability_used.is_connected(_on_ability_used) == false:
		EventBus.ability_used.connect(_on_ability_used)
	set_process(enabled)


func set_enabled(value: bool) -> void:
	enabled = value
	set_process(value)
	queue_redraw()


func _process(delta: float) -> void:
	if InputMap.has_action(toggle_action) and Input.is_action_just_pressed(toggle_action):
		set_enabled(not enabled)
	if Input.is_key_pressed(KEY_F3) and Input.is_key_pressed(KEY_SHIFT):
		set_enabled(true)
	if InputMap.has_action(threat_toggle_action) and Input.is_action_just_pressed(threat_toggle_action):
		show_threat_lines = not show_threat_lines
	if not enabled:
		return

	for floater in _floaters:
		floater.ttl -= delta
		floater.pos.y -= rise_speed * delta
	_floaters = _floaters.filter(func(f): return f.ttl > 0.0)

	for line in _threat_lines:
		line.ttl -= delta
	_threat_lines = _threat_lines.filter(func(l): return l.ttl > 0.0)

	for cd in _cooldowns:
		cd.remaining -= delta
	_cooldowns = _cooldowns.filter(func(c): return c.remaining > 0.0 and is_instance_valid(c.unit))

	queue_redraw()


func _draw() -> void:
	if not enabled:
		return
	var font: Font = ThemeDB.fallback_font
	var size: int = ThemeDB.fallback_font_size
	var xform: Transform2D = get_viewport().get_canvas_transform()
	if font == null:
		return

	if show_threat_lines:
		for line in _threat_lines:
			draw_line(line.a, line.b, line.color, 1.5)
	for floater in _floaters:
		draw_string(font, floater.pos, floater.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, floater.color)

	for unit in _tracked_units:
		if not is_instance_valid(unit):
			continue
		var world_pos := unit.global_position + Vector2(0, -28)
		var bar_pos := xform * world_pos
		_draw_health_bar(unit, bar_pos)
		_draw_status_icons(unit, bar_pos + Vector2(0, -10))

	for cd in _cooldowns:
		if not is_instance_valid(cd.unit):
			continue
		var cd_pos: Vector2 = xform * (cd.unit.global_position + Vector2(0, -42))
		var label := str(snappedf(cd.remaining, 0.1))
		draw_string(font, cd_pos, label, HORIZONTAL_ALIGNMENT_CENTER, -1, size, Color(0.9, 0.9, 0.2))


func _on_damage_dealt(attacker: Node2D, target: Node2D, amount: float) -> void:
	if target == null:
		return
	_add_floater("-" + str(round(amount)), target.global_position, Color(1, 0.3, 0.3))
	_add_threat_line(attacker, target, Color(1, 0.2, 0.2))
	_track_unit(target)


func _on_ability_used(user: Node2D, ability_id: String, target: Node) -> void:
	if target == null:
		return
	var text := ability_id if ability_id != "" else "ability"
	_add_floater(text, target.global_position, Color(0.4, 0.8, 1))
	if target is Node2D:
		_add_threat_line(user, target, Color(0.4, 0.8, 1))
	_track_unit(target)
	_register_cooldown(user, ability_id)


func _add_floater(text: String, world_pos: Vector2, color: Color) -> void:
	var viewport := get_viewport()
	var canvas_pos := world_pos
	if viewport and viewport.world_2d:
		var xform := viewport.get_canvas_transform()
		canvas_pos = xform * world_pos
	_floaters.append({
		"text": text,
		"pos": canvas_pos,
		"color": color,
		"ttl": text_ttl
	})


func _add_threat_line(a: Node2D, b: Node2D, color: Color) -> void:
	if a == null or b == null:
		return
	_threat_lines.append({
		"a": a.global_position,
		"b": b.global_position,
		"ttl": threat_ttl,
		"color": color
	})


func _draw_health_bar(unit: Node2D, screen_pos: Vector2) -> void:
	var health_comp := unit.get_node_or_null("HealthComponent")
	if health_comp == null:
		return
	var current := float(health_comp.current_health)
	var max_hp := maxf(float(health_comp.max_health), 0.001)
	var pct := clampf(current / max_hp, 0.0, 1.0)
	var bar_rect := Rect2(screen_pos - Vector2(health_bar_width * 0.5, 0), Vector2(health_bar_width, health_bar_height))
	draw_rect(bar_rect, Color(0.1, 0.1, 0.1, 0.6))
	var fill_rect := Rect2(bar_rect.position, Vector2(bar_rect.size.x * pct, bar_rect.size.y))
	draw_rect(fill_rect, Color(0.2, 0.9, 0.2, 0.9))


func _draw_status_icons(unit: Node2D, screen_pos: Vector2) -> void:
	var effects: Array = []
	if unit.has_meta("status_effects"):
		effects = unit.get_meta("status_effects")
	var x := screen_pos.x - (effects.size() * (status_icon_size + 2)) * 0.5
	for effect in effects:
		var rect := Rect2(Vector2(x, screen_pos.y), Vector2(status_icon_size, status_icon_size))
		draw_rect(rect, Color(0.9, 0.5, 0.2, 0.9))
		x += status_icon_size + 2


func _register_cooldown(user: Node2D, ability_id: String) -> void:
	if user == null or ability_id == "":
		return
	if not user.has_meta("abilities"):
		return
	for ability in user.get_meta("abilities"):
		if ability.get("id", "") == ability_id:
			var remaining: float = ability.get("cooldown_remaining", 0.0)
			var total: float = ability.get("cooldown", remaining)
			if remaining > 0.0:
				_cooldowns.append({"unit": user, "remaining": remaining, "total": total})
			return


func _track_unit(node: Node) -> void:
	if node is Node2D and node not in _tracked_units:
		_tracked_units.append(node)
