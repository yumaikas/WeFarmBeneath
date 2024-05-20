class_name Game extends Node2D

var forth

var scene
var game = {}
var action_injections = {}
var action_predicates = {}
var action_names = {}
var _log = []

func _ready():
	forth = GDForth.new(self)
	forth.eval(':./game.fth load')
	
func switchScene(to):
	var scn = load(to)
	if scn == null:
		push_error(str("Failed to load: ", to))
		return 1
	else:
		if scene:
			remove_child(scene)
		scene = scn.instance()
		add_child(scene)
		return 0
