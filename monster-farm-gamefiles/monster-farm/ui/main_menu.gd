extends Control
## Main menu scene

func _ready():
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/ContinueButton.pressed.connect(_on_continue_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/CreditsButton.pressed.connect(_on_credits_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	GameState.start_new_game()
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")

func _on_continue_pressed():
	if SaveManager and SaveManager.has_save(0):
		SaveManager.load_game(0)
		get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	else:
		print("No save file found")

func _on_settings_pressed():
	print("Settings menu - TBD")

func _on_credits_pressed():
	print("Credits - TBD")

func _on_quit_pressed():
	get_tree().quit()
