class_name GameFloor 
extends Reference

const done = "completed"
var tileids = {}
var plants = {}
var mobs = {}
var items = {}
var walkable = {}

var dolls = []

func _init(bounds: Rect2):
	for x in range(bounds.position.x, bounds.end.x + 1):
		for y in range(bounds.position.y, bounds.end.y + 1): 
			walkable[Vector2(x, y)] = true
	self.tileids = tileids

func show():
	for d in dolls:
		if is_instance_valid(d):
			d.show()

func hide():
	for d in dolls:
		if is_instance_valid(d):
			d.hide()

func is_walkable(pos: Vector2):
	return walkable.has(pos) and not(mobs.has(pos))

func get_things_at(pos: Vector2):
	var ret = []
	print("Getting things at", pos)
	if mobs.has(pos):
		ret.append(mobs[pos])
	if plants.has(pos):
		ret.append(plants[pos])
	if items.has(pos):
		ret.append(items[pos])
	print("Things", ret)
	return ret
	
func tick_all(amt: int, a: Array):
	for d in a:
		for v in d.values():
			if "tick" in v:
				yield(v.tick(amt, self), done)
	return D.one()

func reap_all(a: Array):
	for d in a:
		var to_reap = []
		for k in d.keys():
			if "live" in d[k] and not d[k].live:
				to_reap.append(k)
			if not is_instance_valid(d[k]):
				to_reap.append(k)
		for k in to_reap:
			d.erase(k)

func tick(amt: int):
	yield(tick_all(amt, [plants, mobs, items]), done)
	reap_all([plants, mobs, items])
		
func tiles() -> Array: 
	var tiles = {}
	for i in 5:
		for j in 5:
			tiles[Vector2(i,j)] = "floor"
	for k in plants.keys():
		tiles.erase(k)
	for k in mobs:
		tiles.erase(k)
	return tiles
