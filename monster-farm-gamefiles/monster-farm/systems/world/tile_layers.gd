extends Node2D
## Collects tilemap layers and provides deterministic demo stamping.

@export var paint_demo: bool = false
@export var map_layout: MapLayoutResource

@onready var terrain: TileMapLayer = get_node_or_null("TerrainLayer")
@onready var buildable: TileMapLayer = get_node_or_null("BuildableLayer")
@onready var nav: TileMapLayer = get_node_or_null("NavLayer")
@onready var hazard: TileMapLayer = get_node_or_null("HazardLayer")
@onready var farming: TileMapLayer = get_node_or_null("FarmingLayer")

# Source indices in placeholder_tileset.tres (order of sub-resources)
const SOURCE_TERRAIN := 0
const SOURCE_BUILDABLE := 1
const SOURCE_HAZARD := 2
const SOURCE_FARMING := 3
const SOURCE_WATER := 4

func _ready() -> void:
	if map_layout:
		apply_layout(map_layout)
	elif paint_demo:
		paint_demo_layout()

func apply_layout(layout: MapLayoutResource) -> void:
	_clear_layers()
	for rect in layout.rects:
		var layer := _layer_for(rect.get("layer", "terrain"))
		var origin: Vector2i = rect.get("origin", Vector2i.ZERO)
		var size: Vector2i = rect.get("size", Vector2i.ZERO)
		var source_id: int = rect.get("source_id", SOURCE_TERRAIN)
		var atlas: Vector2i = rect.get("atlas", Vector2i.ZERO)
		_fill_rect(layer, origin, size, source_id, atlas)

	for cell in layout.cells:
		var layer_cell := _layer_for(cell.get("layer", "terrain"))
		if not layer_cell:
			continue
		var coord: Vector2i = cell.get("coord", Vector2i.ZERO)
		var source_id_cell: int = cell.get("source_id", SOURCE_TERRAIN)
		var atlas_cell: Vector2i = cell.get("atlas", Vector2i.ZERO)
		layer_cell.set_cell(coord, source_id_cell, atlas_cell, 0)

func paint_demo_layout() -> void:
	if not terrain:
		return
	_clear_layers()
	_fill_rect(terrain, Vector2i(-4, -4), Vector2i(12, 12), SOURCE_TERRAIN)
	_fill_rect(farming, Vector2i(-2, 2), Vector2i(6, 3), SOURCE_FARMING)
	_fill_rect(hazard, Vector2i(4, -3), Vector2i(3, 2), SOURCE_HAZARD)
	_fill_rect(nav, Vector2i(-4, -1), Vector2i(12, 1), SOURCE_TERRAIN)
	_fill_rect(buildable, Vector2i(-1, -1), Vector2i(2, 2), SOURCE_BUILDABLE)
	_draw_water_strip()

func _clear_layers() -> void:
	for layer in [terrain, buildable, nav, hazard, farming]:
		if layer:
			layer.clear()

func _layer_for(layer_name: String) -> TileMapLayer:
	match layer_name:
		"terrain":
			return terrain
		"buildable":
			return buildable
		"nav":
			return nav
		"hazard":
			return hazard
		"farming":
			return farming
		_:
			return null

func _fill_rect(layer: TileMapLayer, origin: Vector2i, size: Vector2i, source_id: int, atlas: Vector2i = Vector2i.ZERO) -> void:
	if not layer:
		return
	for y in range(origin.y, origin.y + size.y):
		for x in range(origin.x, origin.x + size.x):
			layer.set_cell(Vector2i(x, y), source_id, atlas, 0)

func _draw_water_strip() -> void:
	if not terrain:
		return
	for x in range(-4, 8):
		terrain.set_cell(Vector2i(x, 3), SOURCE_WATER, Vector2i.ZERO, 0)
		if nav:
			nav.set_cell(Vector2i(x, 3), SOURCE_WATER, Vector2i.ZERO, 0)
