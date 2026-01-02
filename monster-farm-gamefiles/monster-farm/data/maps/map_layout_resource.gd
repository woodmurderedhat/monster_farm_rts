extends Resource
class_name MapLayoutResource

## Rect-based and cell-based tile stamping for TileMapLayer layouts.
## Each entry uses layer keys: "terrain", "buildable", "nav", "hazard", "farming".
@export var rects: Array[Dictionary] = []  # {layer: String, origin: Vector2i, size: Vector2i, source_id: int, atlas: Vector2i = Vector2i.ZERO}
@export var cells: Array[Dictionary] = []  # {layer: String, coord: Vector2i, source_id: int, atlas: Vector2i = Vector2i.ZERO}
