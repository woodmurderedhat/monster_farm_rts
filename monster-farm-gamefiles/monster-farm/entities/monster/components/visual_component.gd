# Visual Component - Manages monster sprite rendering and composition
# Handles layering of base body, element overlays, and mutations
extends Node2D
class_name VisualComponent

## Path to monster art assets
const ART_BASE := "res://art/monsters/"
const BODIES_PATH := ART_BASE + "bodies/"
const OVERLAYS_PATH := ART_BASE + "overlays/"
const MUTATIONS_PATH := ART_BASE + "mutations/"

## Reference to the sprite node (should be parent's Sprite2D)
@onready var base_sprite: Sprite2D = get_parent().get_node("Sprite2D")

## Current visual state
var visual_data: Dictionary = {}
var body_type: String = "wolf"
var element_overlays: Array[Texture2D] = []
var mutation_sprites: Array[Texture2D] = []

func _ready() -> void:
	# Get visual data from monster's metadata (set by MonsterAssembler)
	var parent = get_parent()
	if parent.has_meta("visual_data"):
		visual_data = parent.get_meta("visual_data")
	
	# Load and apply visuals
	apply_visuals()

## Apply visual data to the monster sprite
func apply_visuals() -> void:
	# Get body type from visual data
	body_type = visual_data.get("body_type", "wolf")
	
	# Load base body sprite
	var body_path = BODIES_PATH + body_type + ".png"
	if ResourceLoader.exists(body_path):
		base_sprite.texture = load(body_path)
	else:
		push_warning("VisualComponent: Body sprite not found at %s" % body_path)
	
	# Load and prepare element overlays
	element_overlays.clear()
	if visual_data.has("elements"):
		var elements = visual_data.get("elements", [])
		for element in elements:
			if element is String:
				var overlay_path = OVERLAYS_PATH + "element_" + element + ".png"
				if ResourceLoader.exists(overlay_path):
					element_overlays.append(load(overlay_path))
	
	# Load mutation sprites
	mutation_sprites.clear()
	if visual_data.has("mutations"):
		var mutations = visual_data.get("mutations", [])
		for mutation in mutations:
			if mutation is String:
				var mutation_path = MUTATIONS_PATH + mutation + ".png"
				if ResourceLoader.exists(mutation_path):
					mutation_sprites.append(load(mutation_path))
	
	# Apply scale modifiers if present
	var scale_mod = visual_data.get("scale_modifier", 1.0)
	var base_size = visual_data.get("base_size", 1.0)
	get_parent().scale = Vector2(base_size * scale_mod, base_size * scale_mod)

## Change the visual appearance (for debugging or dynamic changes)
func change_appearance(new_body_type: String, new_elements: Array[String] = [], new_mutations: Array[String] = []) -> void:
	visual_data["body_type"] = new_body_type
	visual_data["elements"] = new_elements
	visual_data["mutations"] = new_mutations
	apply_visuals()

## Get a debug string showing current visuals
func get_visual_info() -> String:
	var info = "Body: %s" % body_type
	if not element_overlays.is_empty():
		info += " | Elements: %d" % element_overlays.size()
	if not mutation_sprites.is_empty():
		info += " | Mutations: %d" % mutation_sprites.size()
	return info
