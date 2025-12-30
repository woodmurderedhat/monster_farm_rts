extends Node2D
## VFX system for ability effects

@export var vfx_duration = 0.3
var particles: CPUParticles2D

func _ready():
	particles = CPUParticles2D.new()
	add_child(particles)
	particles.amount = 8
	particles.lifetime = vfx_duration
	particles.emitting = true

func play_ability_vfx(ability_name: String, vfx_position: Vector2):
	global_position = vfx_position
	
	# Customize particle effect based on ability type
	if "fire" in ability_name.to_lower():
		_setup_fire_vfx()
	elif "water" in ability_name.to_lower():
		_setup_water_vfx()
	elif "lightning" in ability_name.to_lower():
		_setup_lightning_vfx()
	elif "nature" in ability_name.to_lower():
		_setup_nature_vfx()
	else:
		_setup_default_vfx()
	
	# Clean up after effect
	await get_tree().create_timer(vfx_duration).timeout
	queue_free()

func _setup_fire_vfx():
	particles.modulate = Color.ORANGE_RED

func _setup_water_vfx():
	particles.modulate = Color.LIGHT_BLUE

func _setup_lightning_vfx():
	particles.modulate = Color.YELLOW

func _setup_nature_vfx():
	particles.modulate = Color.GREEN

func _setup_default_vfx():
	particles.modulate = Color.WHITE
