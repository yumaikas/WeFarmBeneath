class_name ValueButton extends ToolButton

export var Value: String 

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Value:
		push_error(str("Missing value for button: ", name, "!"))
