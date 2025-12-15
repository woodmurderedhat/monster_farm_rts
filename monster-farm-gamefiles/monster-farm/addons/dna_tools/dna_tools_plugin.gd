# DNA Tools Plugin - Main editor plugin for DNA management
@tool
extends EditorPlugin

const DNAValidatorDock = preload("res://addons/dna_tools/dna_validator_dock.gd")
const MonsterPreviewDock = preload("res://addons/dna_tools/monster_preview_dock.gd")

var validator_dock: Control
var preview_dock: Control


func _enter_tree() -> void:
	# Add validator dock
	validator_dock = DNAValidatorDock.new()
	validator_dock.name = "DNA Validator"
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, validator_dock)
	
	# Add preview dock
	preview_dock = MonsterPreviewDock.new()
	preview_dock.name = "Monster Preview"
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, preview_dock)


func _exit_tree() -> void:
	if validator_dock:
		remove_control_from_docks(validator_dock)
		validator_dock.queue_free()
	
	if preview_dock:
		remove_control_from_docks(preview_dock)
		preview_dock.queue_free()


func _get_plugin_name() -> String:
	return "DNA Tools"

