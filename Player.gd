class_name Player
extends Reference

var pos = Vector2(0,0)

var doll
var inventory: Inventory
var weapon = null

var statuses = []

const done = "completed"

func _init(frame, inventoryToUse: Inventory):
	doll = Proxy.new(frame)
	self.inventory = inventoryToUse

func tick(amt: int, flor: GameFloor):
	for s in statuses:
		s.tick(amt, self, flor)

func move(dir: Vector2, flor: GameFloor):
	if flor.is_walkable(pos + dir):
		pos = pos + dir
		tick(1, flor)
		yield(doll.wait("move_to", [pos]), done)
		var things = flor.get_things_at(pos)
		if len(things) > 0:
			for t in things:
				if t.has_method("walked_over"):
					yield(t.walked_over(self, inventory), done)
		return D.one()
	else:
		var things = flor.get_things_at(pos)
		if len(things) > 0:
			for t in things:
				if t.has_method("combat"):
					yield(t.combat(self, inventory), done)
				if t.has_method("interact"):
					yield(t.interact(self, inventory), done)
		else:
			yield(doll.wait("wiggle"), done)
