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
	moveVM = GDForth.new(self)
	moveVM.eval(_move)
	
func tick(amt: int, flor: GameFloor):
	for s in statuses:
		s.tick(amt, self, flor)

const _move = """
:: try-wait-call ( a m o -- ret/empty ) =o =m =a *m *o .has_method(*) [ *m *a *o .callv(**) ~completed ] if ;

: get-things ( flor -- things ) self .pos swap .get_things_at(*) ;
:: move-me-in-flor ( dir -- ) =dir self dup .pos *dir + >pos ;
: tick-statuses ( flor -- ) 1 swap self .tick(**)! ;

: move-doll-anim ( -- ) self .doll .move_to(*) ~finished ;

:: walk-over-cell ( flor dir ) =dir =flor
	{ self .inventory } =inventory-args
	*dir move-me-in-flor *flor tick-statuses move-doll-anim
	*flor get-things [
		=t *inventory-args :walked_over *t try-wait-call 
	] each
;

:: move ( dir flor -- ) true >moving  =flor =dir 
	{ self .inventory } =inventory-args
	self .pos *dir + *flor .is_walkable(*) 
		[ *flor *dir walk-over-cell ] 
		[ 
			get-things dup =things [
				*inventory-args :combat *t try-wait-call
				*inventory-args :interact *t try-wait-call
			] each
			*things .empty() [ self .doll .wiggle() ~finished ] if
		]
		if-else
	self false >moving
	:completed self .emit_signal(*)!
;

"""

func move(dir: Vector2, flor: GameFloor):
	print("MOVE", moving, dir, flor)
	if not moving:
		moveVM.do("move", dir, flor)
	return self
