extends Node2D
## Farm scene controller

@onready var buildings = $Buildings
@onready var resources = $Resources
@onready var monsters = $Monsters
@onready var farm_panel = $FarmUI/FarmPanel

func _ready():
	load_farm()
	setup_buildings()
	setup_monsters()

func load_farm():
	if GameState and GameState.current_farm:
		var farm_data = GameState.current_farm
		print("Loading farm: %s" % farm_data.get("name", "Farm"))

func setup_buildings():
	# Create placeholder buildings
	var positions = [Vector2(100, 100), Vector2(200, 100), Vector2(300, 100), Vector2(400, 100)]
	var building_names = ["Rest House", "Feeding Station", "Training Arena", "Defense Tower"]
	
	for i in range(4):
		var building = create_building(building_names[i], positions[i])
		buildings.add_child(building)

func create_building(building_name: String, pos: Vector2) -> Node2D:
	var building = Node2D.new()
	building.position = pos
	building.name = building_name
	
	var sprite = Sprite2D.new()
	var color = Color.GRAY
	sprite.texture = _create_building_texture(color, 64, 64)
	building.add_child(sprite)
	
	var label = Label.new()
	label.text = name
	label.modulate = Color.WHITE
	building.add_child(label)
	
	return building

func _create_building_texture(color: Color, w: int, h: int) -> Texture2D:
	var image = Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in range(h):
		for x in range(w):
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)

func setup_monsters():
	# Get assembler
	var assembler = get_node_or_null("/root/GameWorld/MonsterAssembler")
	if not assembler:
		assembler = MonsterAssembler.new()
	
	# Spawn owned monsters in farm
	if GameState and GameState.owned_monsters.size() > 0:
		var positions = [Vector2(100, 300), Vector2(150, 300), Vector2(200, 300)]
		for i in range(min(GameState.owned_monsters.size(), 3)):
			var monster = GameState.owned_monsters[i]
			var spawned = assembler.assemble_monster(monster)
			if spawned:
				spawned.position = positions[i]
				monsters.add_child(spawned)
