extends Node2D

var a = 1
var b = 2
var c = 0

func _ready():
	test()

func test():
	var derp = GDForth.new()
	derp.bind_instance(self)
	derp.load_script(".a .b self :add >c")
	derp.resume()
	print(c)

	derp.load_script("""
	'before-wait print
	 :@get_tree ~idle_frame 
	'after-wait print
	-( Test Comment )-
	""")
	derp.resume()

	yield(derp, "script_end")

	derp.load_script("$0 =a a .b :@add >c")
	derp.resume(4)
	print(c)

	# yield(get_tree(), "idle_frame")
	# derp.load_script("{ 1 2 3 } >c print")
	# derp.resume()
	# print(c)

	yield(get_tree(), "idle_frame")
	derp.load_script("+trace { 1 2 3 } [ print ] each -trace")
	derp.resume()

	yield(get_tree(), "idle_frame")
	derp.load_script("true not print")
	derp.resume()

	# yield(get_tree(), "idle_frame")
	# derp.load_script("false [ 'true ] [ 'false ] if-else >c")
	# derp.resume()
	# print(c)

	# yield(get_tree(), "idle_frame")
	# derp.load_script("0 >a 1 2 3 3 narray [ .a + >a _s ] each")
	# derp.resume()
	# print(a)

	# yield(get_tree(), "idle_frame")
	# derp.load_script("0 1 swap dup _s")
	# derp.resume()
	# print(a)

	# yield(get_tree(), "idle_frame")
	# derp.load_script("{ 1 2 { 3 } } _s")
	# derp.resume()

	# yield(get_tree(), "idle_frame")
	# derp.load_script("[ 1 3 _s derpadd _s >a _s ] trace")
	# derp.resume()
	# print("???, ", a)


func add(i, j):
	return i + j

func _on_StartGameBtn_pressed():
	get_tree().change_scene("res://LevelExperiment.tscn")
