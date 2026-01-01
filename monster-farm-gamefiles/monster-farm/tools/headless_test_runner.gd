# Headless entrypoint for integration tests
extends SceneTree

const IntegrationTestSuite := preload("res://tools/integration_test_suite.gd")
const EXIT_SUCCESS := 0
const EXIT_FAILURE := 1

func _initialize() -> void:
	var root := Node.new()
	root.name = "HeadlessTestRoot"
	get_root().add_child(root)

	var suite := IntegrationTestSuite.new()
	var result: Dictionary = suite.run_all()
	var exit_code := EXIT_SUCCESS if result.get("failed", 0) == 0 else EXIT_FAILURE

	print("\nHeadless integration tests finished with exit code %d" % exit_code)
	if exit_code != EXIT_SUCCESS:
		print("Failed entries:")
		for entry in result.get("log", []):
			if entry.begins_with("FAIL"):
				print("  - " + entry)

	quit(exit_code)
