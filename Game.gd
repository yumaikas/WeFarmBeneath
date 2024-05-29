class_name Game extends Node2D

var forth

var scene
var game = {}
var action_injections = {}
var action_predicates = {}
var action_names = {}
var _log = []

signal game_input(evt)

func _ready():
	print(load("res://monochrome_transparent.png"))
	forth = GDForth.new(self)
	forth.eval(':./project.fth load')
	
func _unhandled_input(event):
	emit_signal("game_input", event)

func card():
    var 

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
