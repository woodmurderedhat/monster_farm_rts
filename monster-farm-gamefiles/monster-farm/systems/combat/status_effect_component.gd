extends Node
class_name StatusEffectComponent
## Status effect system for buffs, debuffs, stuns, etc.

var active_effects: Dictionary = {}  # effect_name -> { duration, strength, tick_timer }
var health_component: HealthComponent = null

func _ready():
	set_process(true)
	# Delay linking to ensure the component is fully added to the scene tree
	call_deferred("_link_health_component")
	print("[DEBUG] HealthComponent state during _ready: %s" % health_component)

func _link_health_component():
	if not is_inside_tree():
		print("[DEBUG] StatusEffectComponent is not inside the scene tree yet.")
		return

	var parent = get_parent()
	if parent:
		print("[DEBUG] Parent Node: %s" % parent)
		print("[DEBUG] Parent Node Type: %s" % parent.get_class())
		print("[DEBUG] Parent Node Full Path: %s" % parent.get_path())
		print("[DEBUG] Parent Node Children:")
		for child in parent.get_children():
			print("[DEBUG] Child Name: %s, Type: %s" % [child.name, child.get_class()])

	health_component = parent.get_node_or_null("HealthComponent")
	if health_component:
		print("[DEBUG] HealthComponent linked: %s" % health_component)
	else:
		print("[DEBUG] HealthComponent not found during linking.")

func apply_status(effect_name: String, duration: float, strength: float = 1.0):
	var data: Dictionary = active_effects.get(effect_name, {"duration": 0.0, "strength": 0.0, "tick_timer": 0.0})
	data["duration"] = max(data["duration"], duration)
	data["strength"] = max(data["strength"], strength)
	data["tick_timer"] = 0.0
	active_effects[effect_name] = data
	_on_effect_applied(effect_name, data["strength"])

func remove_status(effect_name: String):
	if active_effects.has(effect_name):
		active_effects.erase(effect_name)
		_on_effect_removed(effect_name)

func has_status(effect_name: String) -> bool:
	return active_effects.has(effect_name)

func get_status_strength(effect_name: String) -> float:
	if active_effects.has(effect_name):
		return active_effects[effect_name]["strength"]
	return 0.0

func _process(delta):
	if not health_component:
		print("[DEBUG] HealthComponent is null during _process().")
		return
	print("[DEBUG] Processing active effects with HealthComponent: %s" % health_component)
	print("[DEBUG] HealthComponent state during _process: %s" % health_component)
	var to_remove: Array[String] = []
	for effect_name in active_effects.keys():
		var data: Dictionary = active_effects[effect_name]
		print("[DEBUG] Effect: %s, Duration: %.2f, Tick Timer: %.2f" % [effect_name, data["duration"], data["tick_timer"]])
		data["duration"] -= delta
		data["tick_timer"] += delta
		if effect_name in ["poison", "burn"] and data["tick_timer"] >= 1.0:
			_apply_dot(effect_name, data["strength"])
			data["tick_timer"] = 0.0
		active_effects[effect_name] = data
		if data["duration"] <= 0:
			to_remove.append(effect_name)
	for effect_name in to_remove:
		remove_status(effect_name)

func _apply_dot(effect_name: String, strength: float) -> void:
	if not health_component:
		print("[DEBUG] HealthComponent not found during _apply_dot().")
		return
	print("[DEBUG] Applying DoT effect: %s to HealthComponent: %s" % [effect_name, health_component])

	var dmg := 0.0
	match effect_name:
		"poison":
			dmg = 2.0 * strength
		"burn":
			dmg = 3.0 * strength

	print("[DEBUG] Attempting to apply %s damage: %.2f to HealthComponent." % [effect_name, dmg])
	if dmg > 0.0:
		health_component.take_damage(dmg, null)
		print("[DEBUG] Damage applied successfully.")
	else:
		print("[DEBUG] No damage to apply.")

func _on_effect_applied(effect_name: String, strength: float):
	match effect_name:
		"stun":
			if get_parent().has_method("set_stunned"):
				get_parent().set_stunned(true)

func _on_effect_removed(effect_name: String):
	match effect_name:
		"stun":
			if get_parent().has_method("set_stunned"):
				get_parent().set_stunned(false)

func get_all_active_effects() -> Array:
	return active_effects.keys()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		print("[DEBUG] StatusEffectComponent is being deleted.")
	if health_component:
		print("[DEBUG] HealthComponent Reference during deletion: %s" % health_component)
