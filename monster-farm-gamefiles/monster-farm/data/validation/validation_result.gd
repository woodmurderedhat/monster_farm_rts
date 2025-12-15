# Validation Result - Represents a single validation issue
# Used by editor tools and runtime checks
extends Resource
class_name ValidationResult

## Severity level of the validation issue
@export_enum("Info", "Warning", "Error")
var severity: int = 0

## Human-readable message describing the issue
@export var message: String = ""

## ID of the source DNA part that caused the issue
@export var source_id: String = ""


## Static factory methods for creating results
static func info(msg: String, source: String = "") -> ValidationResult:
	var result := ValidationResult.new()
	result.severity = 0
	result.message = msg
	result.source_id = source
	return result


static func warning(msg: String, source: String = "") -> ValidationResult:
	var result := ValidationResult.new()
	result.severity = 1
	result.message = msg
	result.source_id = source
	return result


static func error(msg: String, source: String = "") -> ValidationResult:
	var result := ValidationResult.new()
	result.severity = 2
	result.message = msg
	result.source_id = source
	return result


## Check if this is an error
func is_error() -> bool:
	return severity == 2


## Check if this is a warning
func is_warning() -> bool:
	return severity == 1


## Check if this is info
func is_info() -> bool:
	return severity == 0


## Get severity as string
func get_severity_name() -> String:
	match severity:
		0: return "Info"
		1: return "Warning"
		2: return "Error"
		_: return "Unknown"


## Format as a string for logging
func format() -> String:
	var prefix := "[%s]" % get_severity_name()
	if not source_id.is_empty():
		prefix += " (%s)" % source_id
	return "%s %s" % [prefix, message]

