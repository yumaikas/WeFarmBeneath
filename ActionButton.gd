extends TextureButton

export (String) var action

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("button_down", self, "_do_pressed")
	connect("button_up", self, "_do_released")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _do_pressed():
	Input.action_press(action)
	
func _do_released():
	Input.action_release(action)
