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
var debugVM
signal completed()

func _init(frame, inventoryToUse: Inventory):
	doll = frame
	self.inventory = inventoryToUse
	moveVM = GDForth.new()
	moveVM.bind_instance(self)
	debugVM = GDForth.new("", moveVM)

func tick(amt: int, flor: GameFloor):
	for s in statuses:
		s.tick(amt, self, flor)

const _move  = """
true >moving
$0 =dir $1 =flor

'try-wait-call [ +scope 
	=o =m =a o :has_method( m ) [ o :callv( m a ) ~completed ] if
-scope ] def

'get-things [ flor :get_things_at( .pos ) ] def

'move-me-in-floor [ .pos dir + >pos ] def

-( Tick each of our statuses for 1 tick )-
'tick-statuses [  :@tick( 1 flor ) ] def
'move-doll-anim [ .doll :move_to( .pos ) ~finished ] def

'walk-over-cell [ 
	move-me-in-floor tick-statuses move-doll-anim
	get-things [ =t inventory-args 'walked_over t try-wait-call ] each  
 ] def

{ self .inventory } =inventory-args

flor :is_walkable( .pos dir + )
[ walk-over-cell ] [ 
	get-things dup =things [ =t
		inventory-args 'combat t try-wait-call
		inventory-args 'interact t try-wait-call
	] each
	things :empty() [ .doll :wiggle() ~finished ] if
] if-else 
false >moving
:@emit_signal( 'completed )
"""

func move(dir: Vector2, flor: GameFloor):
	print("MOVE", moving, dir, flor)
	if not moving:
		moveVM.load_script(_move)
		moveVM.resume(dir, flor)
	return self
