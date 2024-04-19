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
    moveVM.eval(_move)
	# debugVM = GDForth.new("", moveVM)

func tick(amt: int, flor: GameFloor):
	for s in statuses:
		s.tick(amt, self, flor)

const _move = """
:: try-wait-call ( a m o -- ret/empty ) =o =m =a *o &has_method( *m ) [ *o &callv( *m *a ) ~completed ] if ;

: get-things ( flor -- ) &get_things_at( .pos ) ;
:: move-me-in-flor ( dir -- ) =dir .pos dir + >pos ;
:: tick-statuses ( flor -- ) =flor self &tick( 1 *flor ) ;

: move-doll-anim ( -- ) .doll &move_to( .pos ) ~finished ;

:: walk-over-cell ( flor dir ) =dir =flor
    { self .inventory } =inventory-args
    *dir move-me-in-flor *flor tick-statuses move-doll-anim
    *flor get-things [
        =t *inventory-args :walked_over *t try-wait-call 
    ] each
;

:: move ( dir flor -- ) true >moving  =flor =dir 
    { self .inventory } =inventory-args
    *flor &is_walkable( .pos *dir + ) 
        [ *flor *dir walk-over-cell ] 
        [ 
            get-things dup =things [
                *inventory-args :combat *t try-wait-call
                *inventory-args :interact *t try-wait-call
            ] each
            *things &emtpy() [ .doll &wiggle() ~finished ] if
        ]
        if-else
    false >moving
    self &emit_signal( :completed )
;

"""

func move(dir: Vector2, flor: GameFloor):
	print("MOVE", moving, dir, flor)
	if not moving:
        moveVM.do("move", dir, flor)
	return self
