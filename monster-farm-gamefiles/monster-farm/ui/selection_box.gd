# Selection Box - Visual representation of the selection marquee
extends Control
class_name SelectionBox

## Box color
@export var box_color: Color = Color(0.2, 0.6, 1.0, 0.3)

## Border color
@export var border_color: Color = Color(0.2, 0.6, 1.0, 0.8)

## Border width
@export var border_width: float = 2.0

## Start position (screen space)
var start_pos: Vector2 = Vector2.ZERO

## End position (screen space)
var end_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Make sure we cover the whole screen
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	if not visible:
		return
	
	var rect := _get_rect()
	
	# Draw fill
	draw_rect(rect, box_color, true)
	
	# Draw border
	draw_rect(rect, border_color, false, border_width)


## Set the box corners
func set_box(start: Vector2, end: Vector2) -> void:
	start_pos = start
	end_pos = end
	queue_redraw()


## Get the rectangle from start/end positions
func _get_rect() -> Rect2:
	var min_pos := Vector2(minf(start_pos.x, end_pos.x), minf(start_pos.y, end_pos.y))
	var max_pos := Vector2(maxf(start_pos.x, end_pos.x), maxf(start_pos.y, end_pos.y))
	return Rect2(min_pos, max_pos - min_pos)
