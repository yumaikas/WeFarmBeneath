class_name Player
extends Reference

var pos = Vector2(0,0)

var doll
var inventory: Inventory
var weapon = null

var statuses = []

const done = "completed"
var moveVM
var moving = false
signal completed()

func _init(frame, inventoryToUse: Inventory):
	doll = frame
	self.inventory = inventoryToUse
	moveVM = GDForth.new()
	moveVM.bind_instance(self)

func tick(amt: int, flor: GameFloor):
	for s in statuses:
		s.tick(amt, self, flor)

const _move  = """
true >moving
$0 =dir $1 =flor
$0 print
$1 print

'try-wait-call [ =o =m =a m o :has_method [ m a o :callv ~completed ] if ] def
'get-things [ .pos flor :get_things_at ] def

{ self .inventory } =inventory-args
.pos dir + flor :is_walkable 
[ 
	.pos dir + >pos 
	1 .flor :@tick

	 .pos .doll _s :move_to _s ~finished

	.pos flor :get_things_at =things
	[ get-things [ =t inventory-args 'walked_over t try-wait-call ] each ] trace
] [ 
	get-things dup =things [ =t
		inventory-args 'combat t try-wait-call
		inventory-args 'interact t try-wait-call
	] each
	things :empty [ .doll :wiggle ~finished ] if
] if-else 
false >moving
:@finish 
"""

func finish():
	emit_signal("completed")

func move(dir: Vector2, flor: GameFloor):
	if not moving:
		moveVM.load_script(_move)
		moveVM.resume(dir, flor)
	return self

	# if flor.is_walkable(pos + dir):
	# 	pos = pos + dir
	# 	tick(1, flor)
	# 	yield(doll.wait("move_to", [pos]), done)
	# 	var things = flor.get_things_at(pos)
	# 	if len(things) > 0:
	# 		for t in things:
	# 			if t.has_method("walked_over"):
	# 				yield(t.walked_over(self, inventory), done)
	# 	return D.one()
	# else:
	# 	var things = flor.get_things_at(pos)
	# 	if len(things) > 0:
	# 		for t in things:
	# 			if t.has_method("combat"):
	# 				yield(t.combat(self, inventory), done)
	# 			if t.has_method("interact"):
	# 				yield(t.interact(self, inventory), done)
	# 	else:
	# 		yield(doll.wait("wiggle"), done)
