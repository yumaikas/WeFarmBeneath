class_name Game
extends Reference

var levels = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init(start_levels: Array):
	levels = start_levels
	
static func setup():
	var f1 = Floor.new(Rect2(0,0, 4, 4))
	.new([f1])

func do_event(type: String, data: Dictionary):
	if type == "tick":
		for l in levels:
			l.tick(data.amt)

class Floor extends Reference:
	var tileids = {}
	var plants = {}
	var mobs = {}
	var walkable = {}
	var tickers = []
	
	func _init(bounds: Rect2):
		for x in range(bounds.position.x, bounds.end.x + 1):
			for y in range(bounds.position.y, bounds.end.y + 1): 
				walkable[Vector2(x, y)] = true
		self.tileids = tileids
	
	func is_walkable(pos: Vector2):
		return walkable.has(pos) and not(mobs.has(pos))
		
	func tick(amt: int):
		for t in tickers:
			t.tick(amt, self)
			
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

class Mob extends Reference:
	var doll
	var logic
	
	func _init(mob_logic):
		self.logic = mob_logic
	
	func tick(amt: int, flor: Floor):
		logic.tick(amt, flor, doll)
		
