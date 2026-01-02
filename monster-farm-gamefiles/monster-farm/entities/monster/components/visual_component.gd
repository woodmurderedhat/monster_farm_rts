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
@onready var overlay_layer: Node2D = _ensure_layer("OverlayLayer")
@onready var mutation_layer: Node2D = _ensure_layer("MutationLayer")
@onready var status_layer: Node2D = _ensure_layer("StatusEffectLayer")
@onready var ability_vfx_layer: Node2D = _ensure_layer("AbilityVFXLayer")

@export var damage_flash_color: Color = Color(1, 0.2, 0.2, 0.6)
@export var damage_flash_time: float = 0.2
@export var cast_anim: String = "cast"
@export var hit_anim: String = "hit"
@export var idle_anim: String = "idle"
var _flash_timer: float = 0.0
var _anim_player: AnimationPlayer
var _anim_tree: AnimationTree

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
	_connect_signals()
	_anim_player = parent.get_node_or_null("AnimationPlayer")
	_anim_tree = parent.get_node_or_null("AnimationTree")
	# Load and apply visuals
	apply_visuals()
	set_process(true)

func _process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta
		var t := clampf(_flash_timer / max(damage_flash_time, 0.001), 0.0, 1.0)
		base_sprite.modulate = damage_flash_color.lerp(Color(1, 1, 1, 1), 1.0 - t)
	else:
		base_sprite.modulate = Color(1, 1, 1, 1)

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


func _connect_signals() -> void:
	if EventBus.damage_dealt.is_connected(_on_damage_dealt) == false:
		EventBus.damage_dealt.connect(_on_damage_dealt)
	if EventBus.ability_used.is_connected(_on_ability_used) == false:
		EventBus.ability_used.connect(_on_ability_used)


func _on_damage_dealt(_attacker: Node2D, target: Node2D, _amount: float) -> void:
	if target == get_parent():
		_flash_timer = damage_flash_time
		_play_hit_anim()


func _on_ability_used(user: Node2D, _ability_id: String, _target: Node) -> void:
	if user == get_parent():
		# Simple indicator placeholder: brief flash on overlay layer
		_flash_timer = damage_flash_time * 0.7
		_play_cast_anim()


func _ensure_layer(layer_name: String) -> Node2D:
	var parent := get_parent()
	if parent.has_node(layer_name):
		return parent.get_node(layer_name) as Node2D
	var layer := Node2D.new()
	layer.name = layer_name
	# Defer adding children during scene setup to avoid "Parent node is busy" errors
	parent.call_deferred("add_child", layer)
	return layer


func _play_cast_anim() -> void:
	if _anim_tree and _anim_tree.active:
		if _anim_tree.has("parameters/State/current"):
			_anim_tree.set("parameters/State/current", cast_anim)
	elif _anim_player and _anim_player.has_animation(cast_anim):
		_anim_player.play(cast_anim)


func _play_hit_anim() -> void:
	if _anim_tree and _anim_tree.active:
		if _anim_tree.has("parameters/State/current"):
			_anim_tree.set("parameters/State/current", hit_anim)
	elif _anim_player and _anim_player.has_animation(hit_anim):
		_anim_player.play(hit_anim)

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
