# Integration helper - Shows which sprites are available
# This script validates that artwork matches DNA resources
extends Node

const BODIES_DIR = "res://art/monsters/bodies/"
const OVERLAYS_DIR = "res://art/monsters/overlays/"
const MUTATIONS_DIR = "res://art/monsters/mutations/"

static func get_available_body_types() -> Array[String]:
	"""Return list of available body type sprites."""
	var types: Array[String] = []
	var dir = DirAccess.open(BODIES_DIR)
	if dir:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.ends_with(".png"):
				types.append(filename.trim_suffix(".png"))
			filename = dir.get_next()
	return types

static func get_available_elements() -> Array[String]:
	"""Return list of available element overlays."""
	var elements: Array[String] = []
	var dir = DirAccess.open(OVERLAYS_DIR)
	if dir:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.starts_with("element_") and filename.ends_with(".png"):
				elements.append(filename.trim_prefix("element_").trim_suffix(".png"))
			filename = dir.get_next()
	return elements

static func get_available_mutations() -> Array[String]:
	"""Return list of available mutation sprites."""
	var mutations: Array[String] = []
	var dir = DirAccess.open(MUTATIONS_DIR)
	if dir:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.ends_with(".png"):
				mutations.append(filename.trim_suffix(".png"))
			filename = dir.get_next()
	return mutations

static func print_available_assets() -> void:
	"""Print all available art assets for debugging."""
	print("\n=== Available Monster Art Assets ===")
	print("Bodies: ", get_available_body_types())
	print("Elements: ", get_available_elements())
	print("Mutations: ", get_available_mutations())
	print("====================================\n")
