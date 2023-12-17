extends Sprite

var color_map = { "copper": "d14203", "silver": "dfdfdf", "gold": "fdff00" }
export (Color) var copper = Color("d14203") 
export (Color) var silver = Color("dfdfdf")
export (Color) var gold = Color("fdff00")


var _map: TileMap
var amt: int


var _is_bound = false
var _bound_to: WeakRef

func _ready():
	pass # Replace with function body.

func setup(map, color):
	_map = map 
	set_color(color)

func bind_to(other):
	_is_bound = true
	_bound_to = weakref(other)

func _process(_delta):
	if _is_bound and _bound_to.get_ref() == null:
		queue_free()


func set_color(to):
	print("set_color", to)
	if to in ["copper", "silver", "gold"]:
		modulate = Color(color_map[to])

func bounce():
	pass

func set_pos_to(pos: Vector2):
	position = _map.map_to_world(pos)
