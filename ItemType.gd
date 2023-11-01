class_name ItemType

const types = {}

var id
var display_name

static func create(id: String, display_name: String):
	if types.has(id):
		return id
	else:
		var t = .new(id, display_name)
		types[id] = t
		return t

func _init(id: String, display_name: String):
	self.id = id
	self.display_name = display_name
