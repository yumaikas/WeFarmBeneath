class_name GameForth extends Reference

var levels = []
var level_idx: int
var _player

onready var forth = GDForth.new(self)
func _ready():
    forth.eval("""
    :roll ( l h -- rand ) Util.R(**) ;
    :: setup ( item-factory player ) =player =factory
    0 4 roll =pos-r
    0 0 4 4 Rect2(****) GameFloor.New(*) =f1

    
    ;
    """)
    
