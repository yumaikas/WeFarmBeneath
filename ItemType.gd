class_name ItemType

const types = {}

static func create(id: String, display_name: String):
	if types.has(id):
		return id
	else:
		var t = ItemTypeData.new(id, display_name)
		types[id] = t
		return t

static func sort(a: ItemTypeData, b: ItemTypeData):
	return a.id < b.id

class ItemTypeData:
	var id
	var display_name

	func _init(id: String, display_name: String):
		self.id = id
		self.display_name = display_name
