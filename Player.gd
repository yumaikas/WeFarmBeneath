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

'try-wait-call [ +scope 
	=o =m =a m o :has_method [ m a o :callv ~completed ] if
-scope ] def

'get-things [ .pos flor :get_things_at ] def

'move-me-in-floor [ .pos dir + >pos ] def

-( Tick each of our statuses for one t )-
'tick-statuses [ 1 flor :@tick ] def
'move-doll-anim [ .pos .doll :move_to ~finished ] def

'walk-over-cell [ 
	move-me-in-floor
	tick-statuses
	move-doll-anim

	.pos flor :get_things_at =things
	get-things [ =t inventory-args 'walked_over t try-wait-call ] each  
 ] def

{ self .inventory } =inventory-args

.pos dir + flor :is_walkable 
[ walk-over-cell ] [ 
	get-things dup =things [ =t
		inventory-args 'combat t try-wait-call
		inventory-args 'interact t try-wait-call
	] each
	things len zero? [ .doll :wiggle ~finished ] if
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


