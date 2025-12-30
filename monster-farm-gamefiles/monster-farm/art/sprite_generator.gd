extends Node2D
## Placeholder sprite generator for monsters

static func generate_monster_sprite(monster_id: String) -> Sprite2D:
	var sprite = Sprite2D.new()
	var shape_color = _get_color_for_monster(monster_id)
	var texture = _create_placeholder_texture(shape_color, 64, 64)
	sprite.texture = texture
	sprite.scale = Vector2(0.5, 0.5)
	return sprite

static func _get_color_for_monster(monster_id: String) -> Color:
	var hash_value = monster_id.hash() % 5
	match hash_value:
		0: return Color.DARK_RED  # Wolf
		1: return Color.YELLOW    # Drake
		2: return Color.DARK_GRAY  # Golem
		3: return Color.DARK_GREEN # Sprite
		4: return Color.DARK_BLUE  # Beetle
		_: return Color.WHITE

static func _create_placeholder_texture(color: Color, width: int, height: int) -> ImageTexture:
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	
	# Draw circle
	for y in range(height):
		for x in range(width):
			var dx = x - width / 2.0
			var dy = y - height / 2.0
			var dist = sqrt(dx * dx + dy * dy)
			if dist < width / 2.0 - 4:
				image.set_pixel(x, y, color)
			elif dist < width / 2.0:
				image.set_pixel(x, y, color.lightened(0.5))
	
	return ImageTexture.create_from_image(image)

static func generate_ui_button() -> Texture2D:
	var image = Image.create(100, 40, false, Image.FORMAT_RGBA8)
	
	for y in range(40):
		for x in range(100):
			image.set_pixel(x, y, Color(0.3, 0.3, 0.3, 1))
	
	return ImageTexture.create_from_image(image)
