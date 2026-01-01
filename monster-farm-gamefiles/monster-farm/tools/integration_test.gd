# Integration Test Script
# Editor entrypoint that delegates to the shared headless-capable suite
extends EditorScript

const IntegrationTestSuite := preload("res://tools/integration_test_suite.gd")

func _run() -> void:
	var suite := IntegrationTestSuite.new()
	var result: Dictionary = suite.run_all()
	
	if result.get("failed", 0) > 0:
		print("Failed entries:")
		for entry in result.get("log", []):
			if entry.begins_with("FAIL"):
				print("  - " + entry)
