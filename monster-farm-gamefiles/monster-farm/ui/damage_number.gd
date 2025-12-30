extends Node2D
## Damage number display system

var damage_label: Label
var floating_start_pos: Vector2
var total_duration = 0.5
var elapsed_time = 0.0
var damage_amount = 0

func _ready():
	damage_label = Label.new()
	damage_label.add_theme_font_size_override("font_size", 24)
	add_child(damage_label)

func show_damage(amount: int, hit_position: Vector2, color: Color = Color.RED):
	damage_amount = amount
	global_position = hit_position
	floating_start_pos = hit_position
	elapsed_time = 0.0
	
	damage_label.text = str(amount)
	damage_label.add_theme_color_override("font_color", color)
	
	set_process(true)

func show_heal(amount: int, hit_position: Vector2):
	show_damage(amount, hit_position, Color.GREEN)

func _process(delta):
	elapsed_time += delta
	
	# Float up and fade out
	var progress = elapsed_time / total_duration
	global_position = floating_start_pos + Vector2(0, -50 * progress)
	
	var modulate_color = damage_label.modulate
	modulate_color.a = 1.0 - progress
	damage_label.modulate = modulate_color
	
	if progress >= 1.0:
		queue_free()
