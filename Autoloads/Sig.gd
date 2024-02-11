class_name GDForth
extends Object

signal script_end()

var m
var floatPat
var intPat
var IP = -1
var stack_stack = []
var stack = []
var trace = false
var returnStack = []
var dict = {}
var locals = {}
var stop = false
var is_error = false
var CODE 
var errSymb = {}
var lblSymb = {}
var iterSymb = {}
var instance
var instance_meta = {}

var _stdlib = """
'if [ [ ] if-else ] def
"""

func _init():
	m = RegEx.new()
	m.compile("\\S+")

	intPat = RegEx.new()
	intPat.compile("^-?\\d+$")
	floatPat = RegEx.new()
	floatPat.compile("^-\\d+.?\\d*$")

func load_script(script):
	CODE = []
	stack = []
	locals = {}
	var matches = m.search_all(_stdlib + script)
	for m in matches:
		CODE.append(m.strings[0])

	IP = 0
	stop = false

func load_method_table(of):
	var id = of.get_meta("METHOD_TABLE_KEY")
	if not id:
		id = str(of.get_class(), of.get_script())
	if instance_meta.has(id):
		of.set_meta("METHOD_TABLE_KEY", id)
		return instance_meta[id]
	var meta = {}
	for m in of.get_method_list():
		meta[m.name] = len(m.args)
	instance_meta[id] = meta
	return meta

func immediate_script(script):
	load_script(script)
	resume()

func bind_instance(to):
	instance = to
	load_method_table(to)

func _r_push(e):
	returnStack.append(e)

func _r_pop():
	if len(returnStack) == 0:
		is_error = true
		stop = true
		return {errSymb: "RETURN UNDERFLOW"}
	return returnStack.pop_back()

func _push(e):
	stack.append(e)

func _pop():
	if len(stack) > 0:
		return stack.pop_back()
	else:
		is_error = true
		stop = true
		return {errSymb: "DATA UNDERFLOW"}
	
func _is_special(item, symb):
	return typeof(item) == TYPE_DICTIONARY and item.has(symb)

func _pop_special(symb):
	if symb in stack.back():
		return stack.pop_back()
	else:
		is_error = true
		stop = true
		return {errSymb: "SPECIAL POP MISMATCH"}
	
func _do_call(instance, inst):
	var method = inst.substr(1)
	var meta = load_method_table(instance)
	if instance.has_method(method):
		var args = []
		for n in meta[method]:
			args.append(_pop())
		args.invert()

		var ret = instance.callv(method, args)
		print("CALL: ", instance, method, args, " RETURNED: ", ret)
		if ret != null:
			_push(ret)

const math_ops = ["+", "-", "*", "div"]

func math(inst):
	var b = _pop()
	var a = _pop()
	if inst == "+":
		_push(a + b)
	elif inst == "-":
		_push(a - b)
	elif inst == "*":
		_push(a * b)
	elif inst == "div":
		_push(a / b)

# The parameters are an attempt to make 
# this a -very- widely compatible
# signal handler
func resume(a0=null,a1=null,a2=null,a3=null,a4=null,a5=null,a6=null,a7=null,a8=null,a9=null):
	var args =[a0,a1,a2,a3,a4,a5,a6,a7,a8,a9]
	if is_error:
		push_error("Attempted to resume failed GDForth script")
		return
	stop = false
	while IP < len(CODE) and not stop:
		var inst = CODE[IP]
		if trace:
			print("TRACE: ", inst, " DATA:", stack)
		if typeof(inst) == TYPE_STRING:
			if inst.begins_with("."):
				_push(instance.get(inst.substr(1)))
				
			elif inst.begins_with(">"):
				var val = _pop()
				instance.set(inst.substr(1), val)
			elif inst.begins_with(":@"):
				_do_call(instance, inst.substr(1))
			elif inst.begins_with(":"):
				var _self = _pop()
				_do_call(_self, inst)

			elif inst.begins_with("$"):
				if inst.substr(1) in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]:
					_push(args[int(inst.substr(1))])
				else:
					stop = true
					is_error = true
			elif inst.begins_with("'"):
				CODE[IP] = ["LIT", inst.substr(1)]
				continue
			elif inst.begins_with("~"):
				CODE[IP] = ["WAIT", inst.substr(1)]
				continue
			elif inst == "print":
				print(_pop())
			elif inst == "self":
				_push(instance)
			elif inst == "swap":
				CODE[IP] = ["PICK-DEL", [-2], [-2]]
				continue
			elif inst == "dup":
				CODE[IP] = ["DUP-AT", [-1]]
			elif inst == "drop":
				CODE[IP] = ["PICK-DEL", [], [-1]]
			elif inst == "_s":
				print(stack)
			elif inst in math_ops:
				math(inst)
			elif inst.begins_with("="):
				locals[inst.substr(1)] = _pop()
			elif inst == "narray":
				var n = _pop()
				var top = []
				for i in n:
					top.append(_pop())
				top.invert()
				_push(top)
			elif inst == "nth":
				var at = _pop()
				var arr = _pop()
				_push(arr[at])
			elif inst == "def":
				var block = _pop()
				var name = _pop()
				dict[name] = block
			elif inst == "if-else":
				var false_lbl = _pop_special(lblSymb)
				var true_lbl = _pop_special(lblSymb)
				var cond = _pop()
				# Push the IP -after- the if-else onto the return stack
				# so that when we hit the end
				# we return to that instruction
				if cond:
					_r_push(IP+1)
					IP = true_lbl[lblSymb]
					continue
				else:
					_r_push(IP+1)
					IP = false_lbl[lblSymb]
					continue
			elif inst == "each":
				var blockdef = _pop()
				var iter = _pop()
				CODE[IP] = ["EACH", blockdef, {
					"idx": 0,
					"iter": iter
				}]
				continue
			elif inst == "trace":
				var blockdef = _pop_special(lblSymb)
				trace = true
				_r_push(IP)
				CODE[IP] = ["TRACE"]
				IP = blockdef[lblSymb]
				continue
			elif inst == "{":
				stack_stack.append(stack.duplicate())
			elif inst == "}":
				var prev_stack = stack_stack.pop_back()
				var new_elems = stack.slice(len(prev_stack), len(stack))
				prev_stack.append(new_elems)
				stack = prev_stack

			elif inst == "[":
				var SEEK = IP+1
				var DEPTH = 1
				while DEPTH > 0:
					if CODE[SEEK] == "[":
						DEPTH += 1
					elif CODE[SEEK] == "]":
						DEPTH -= 1
					if SEEK > len(CODE):
						stop = true
						is_error = true
						push_error("Unmatched [")
						break
					SEEK += 1
				SEEK -= 1
				CODE[IP] = ["BLOCK-LIT", SEEK, {lblSymb: IP+1}]
				IP -= 1
			elif inst == "]":
				IP = _r_pop()
				continue
			elif inst == "true":
				CODE[IP] = ["LIT", true]
				continue
			elif inst == "false":
				CODE[IP] = ["LIT", false]
				continue
			elif intPat.search(inst):
				CODE[IP] = ["LIT", int(inst)]
				continue
			elif floatPat.search(inst):
				CODE[IP] = ["LIT", float(inst)]
				continue
			elif inst in dict:
				CODE[IP] = ["CALL", dict[inst][lblSymb]]
				continue
			elif inst in locals:
				CODE[IP] = ["GETVAR", inst]
				continue
			else:
				stop = true
				is_error = true
				print("ERROR: unresolved word: ", inst, "at ", IP)
				print(CODE)
				
		elif typeof(inst) == TYPE_ARRAY:
			if inst[0] == "LIT":
				_push(inst[1])
			elif inst[0] == "GETVAR":
				_push(locals[inst[1]])
			elif inst[0] == "CALL":
				_r_push(IP+1)
				IP = inst[1]
				continue
			elif inst[0] == "WAIT":
				var obj = _pop()
				obj.connect(inst[1], self, "resume")
				stop = true
			elif inst[0] == "DUP-AT":
				var to_add = []
				for idx in inst[1]:
					to_add.append(stack[idx])
				stack.append_array(to_add)
			elif inst[0] == "PICK-DEL":
				var to_add = []
				for idx in inst[1]:
					to_add.append(stack[idx])
				for idx in inst[2]:
					stack.pop_at(idx)
				stack.append_array(to_add)

			elif inst[0] == "BLOCK-LIT":
				IP = inst[1]
				_push(inst[2])
			elif inst[0] == "TRACE":
				trace = false
				CODE[IP] = "trace"
			elif inst[0] == "EACH":
				var blockdef = inst[1]
				var iterState = inst[2]
				if iterState.idx >= len(iterState.iter):
					CODE[IP] = "each"
				else:
					_r_push(IP)
					IP = blockdef[lblSymb]
					_push(iterState.iter[iterState.idx])
					iterState.idx += 1
					continue
			else:
				stop = true
				print(str("Unable to execute inst ", CODE[IP], " at ", IP))
				push_error(str("Unable to execute inst ", CODE[IP], " at ", IP))
				_push(inst)
				break
		IP += 1
	if not stop:
		emit_signal("script_end")
