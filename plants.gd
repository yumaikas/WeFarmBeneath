
class_name Plant 
extends Reference
	
var tile_id: int
var grow_time: int
var on_harvested: Fn
var on_grow: Fn
var total_hitpoints: int
var HP: int
var growth_amt: int

func harvest():
	on_harvested.exec([self])

func tick(amt: int, flor: GameFloor):
	if growth_amt >= grow_time:
		return
	
	for i in amt:
		growth_amt += 1
		on_grow.exec([self])

static func Wheat(tile_ids: Dictionary, inventory: Inventory, doll):
	var w = Plant.new()
	w.tile_id = tile_ids["wheat"]
	w.grow_time = 24
	w.total_hitpoints = 3
	w.on_harvested = Fn.new(inventory, "add_item", [inventory.Wheat])
	w.on_grow = Fn.new(doll, "bounce")
