extends MainLoop

func _init():
	# Preload the StatusEffectComponent script
	var StatusEffectComponent = preload("res://systems/combat/status_effect_component.gd")
	print("[DEBUG] StatusEffectComponent loaded: %s" % StatusEffectComponent)

	# Create a mock parent node with a HealthComponent
	var mock_parent = Node.new()
	mock_parent.name = "MockParent"
	var health_component = Node.new()
	health_component.name = "HealthComponent"
	mock_parent.add_child(health_component)

	# Instantiate the StatusEffectComponent and add it to the mock parent
	var status = StatusEffectComponent.new()
	mock_parent.add_child(status)
	print("[DEBUG] StatusEffectComponent instance: %s" % status)

	# Simulate the _ready lifecycle
	status._ready()

	# Exit the script after execution
	get_tree().quit()

func _process(delta):
	# Ensure the MainLoop remains responsive
	pass