extends Node
## Status effect system for buffs, debuffs, stuns, etc.

var active_effects: Dictionary = {}  # effect_name -> { duration, strength }

func _ready():
	set_process(true)

func apply_status(effect_name: String, duration: float, strength: float = 1.0):
	if not active_effects.has(effect_name):
		active_effects[effect_name] = { "duration": duration, "strength": strength }
		_on_effect_applied(effect_name, strength)
	else:
		# Refresh or stack
		active_effects[effect_name]["duration"] = max(active_effects[effect_name]["duration"], duration)

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
	for effect_name in active_effects.keys():
		active_effects[effect_name]["duration"] -= delta
		if active_effects[effect_name]["duration"] <= 0:
			remove_status(effect_name)

func _on_effect_applied(effect_name: String, strength: float):
	print("Applied %s (strength: %.1f)" % [effect_name, strength])
	match effect_name:
		"stun":
			if get_parent().has_method("set_stunned"):
				get_parent().set_stunned(true)
		"burn":
			print("Monster is burning!")
		"poison":
			print("Monster is poisoned!")

func _on_effect_removed(effect_name: String):
	print("Removed %s" % effect_name)
	match effect_name:
		"stun":
			if get_parent().has_method("set_stunned"):
				get_parent().set_stunned(false)

func get_all_active_effects() -> Array:
	return active_effects.keys()
