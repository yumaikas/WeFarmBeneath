extends Node2D

var a = 5
var b = 6
var c = 0

func _ready():

	test()

func test():

	var derp = GDForth.new()
	derp.bind_instance(self)
	derp.load_script("""
	self :add( .a .b ) >c .c print
	:@add( .a .b ) >c .c print

	{ { '2max 3 4 } 3 4 2max } print
	
	:@derp()

	'wait [ :@get_tree() ~idle_frame ] def
	'before-wait print
	 :@get_tree() ~idle_frame 
	'after-wait print
	-( Test Comment )-
	:@add( .a .b ) >c
	VM :get_incoming_connections() print
	VM print
	:@get_tree() :get_incoming_connections() print
	.c print wait
	{ 1 2 3 } [ print ] each  wait
	true not print wait
	'wait-ended print
	+trace 1 2 'foo -trace

	""")
	derp.resume()

func add(i, j):
	return i + j

func derp():
	print("D E R P")

func _on_StartGameBtn_pressed():
	get_tree().change_scene("res://LevelExperiment.tscn")
