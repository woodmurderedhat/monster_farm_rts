extends CanvasLayer
## Pause menu - handles game pause state

func _ready():
	$VBoxContainer/ResumeButton.pressed.connect(_on_resume)
	$VBoxContainer/SaveButton.pressed.connect(_on_save)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu)
	visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	visible = not visible
	get_tree().paused = visible

func _on_resume():
	toggle_pause()

func _on_save():
	if SaveManager:
		SaveManager.save_game(0)
		print("Game saved!")

func _on_settings():
	print("Settings menu - TBD")

func _on_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
