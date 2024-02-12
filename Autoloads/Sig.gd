class_name GDForth
extends Object

signal script_end()

var m
var floatPat
var intPat
var IP = -1
var nesting_stack = []
var stack = []
var trace = 0
var trace_indent = false
var utilStack = []
var returnStack = []
var dict = {}
var locals = {}
var stop = false
var is_error = false
var CODE 
var errSymb = {}
var lblSymb = {}
var iterSymb = {}
var prevSymb = {}
var instance
var instance_meta = {}

var _stdlib = """
'{ [ stack-size u< ] def
'} [ stack-size u> - narray ] def
'pos? [ 0 gt? ] def
'neg? [ 0 lt? ] def
'zero?  [ 0 eq? ] def
'inc [ 1 + ] def

'not [ [ false ] [ true ] if-else ] def
'trace [ +trace do-block -trace ] def

'if [ [ ] if-else ] def
'do-with-scope [ get-scope u< set-scope do-block u> set-scope ] def
'while [ get-scope +scope 
	=old-scope =block 
	%LOOP 
		block old-scope do-with-scope 
	LOOP goto-if-true
	-scope 
] def

'each [ get-scope +scope 
	=outer =block =arr 0 =idx
	arr len pos? [
		%LOOP 
			arr idx nth block outer do-with-scope 
			1 idx inc =idx
		arr len idx gt? LOOP goto-if-true
	] if
	-scope
] def
"""

func _init(script=null,bind_to=null):
	m = RegEx.new()
	m.compile("\\S+")

	intPat = RegEx.new()
	intPat.compile("^-?\\d+$")
	floatPat = RegEx.new()
	floatPat.compile("^-\\d+.?\\d*$")
	if script:
		load_script(script)
	if bind_to:
		bind_instance(bind_to)

func load_script(script):
	CODE = []
	stack = []
	locals = {}
	var matches = m.search_all(_stdlib + script)
	var drop = false
	for m in matches:
		if m.strings[0] == "-(":
			drop = true
		if m.strings[0] == ")-":
			drop = false
			continue
		if not drop:
			CODE.append(m.strings[0])

	IP = 0
	stop = false
	is_error = false


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

func __pop(stack, errMsg):
	if len(stack) == 0:
		is_error = true
		stop = true
		return {errSymb: errMsg}
	return stack.pop_back()

func _u_push(e):
	utilStack.append(e)

func _u_pop():
	return __pop(utilStack, "UTILITY STACK UNDERFLOW")

func _r_push(e):
	returnStack.append(e)

func _r_pop():
	return __pop(returnStack, "RETURN STACK UNDERFLOW")

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

func _has_prefix(word, pre):
	return typeof(word) == TYPE_STRING and word.begins_with(pre)
	
func _do_call(instance, inst):
	var method = inst.substr(1)
	var meta = load_method_table(instance)
	if instance.has_method(method):
		var args = []
		for n in meta[method]:
			args.append(_pop())
		args.invert()

		var ret = instance.callv(method, args)
		if trace > 0:
			print("CALL: ", instance, method, args, " RETURNED: ", ret)
		if ret != null:
			_push(ret)

const math_ops = ["+", "-", "*", "div", "gt?", "lt?", "ge?", "le?", "eq?"]

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
	elif inst == "gt?":
		_push(a > b)
	elif inst == "lt?":
		_push(a < b)
	elif inst == "ge?":
		_push(a >= b)
	elif inst == "le?":
		_push(a <= b)
	elif inst == "eq?":
		_push(a == b)

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
		if trace > 0:
			print("  ".repeat(trace - 1), 
				"TRACE: ", IP, ", ", inst, " DATA:", stack, " RETURN:", returnStack)
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
			elif inst.begins_with("%"):
				locals[inst.substr(1)] = {lblSymb: IP}
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
			elif inst == "len":
				_push(len(_pop()))
			elif inst == "swap":
				CODE[IP] = ["PICK-DEL", [-2], [-2]]
				continue
			elif inst == "dup":
				CODE[IP] = ["DUP-AT", [-1]]
				continue
			elif inst == "drop":
				CODE[IP] = ["PICK-DEL", [], [-1]]
				continue
			elif inst == "u<":
				CODE[IP] = ["U-PUSH"]
				continue
			elif inst == "u>":
				CODE[IP] = ["U-POP"]
				continue
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
			elif inst == "get":
				var k = _pop()
				var dict = _pop()
				_push(dict[k])
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
					if trace_indent:
						trace+=1
					_r_push(IP+1)
					IP = true_lbl[lblSymb]
					continue
				else:
					if trace_indent:
						trace+=1
					_r_push(IP+1)
					IP = false_lbl[lblSymb]
					continue
			elif inst == "+scope":
				var old_locals = locals
				locals = { prevSymb: old_locals }
			elif inst == "-scope":
				var old_locals = locals[prevSymb]
				locals = old_locals
			elif inst == "get-scope":
				_push(locals)
			elif inst == "set-scope":
				locals = _pop()
			elif inst == "+trace":
				trace += 1
			elif inst == "-trace":
				trace = max(trace - 1, 0)
			elif inst == "goto-if-true":
				var JUMP = _pop_special(lblSymb)[lblSymb]
				if _pop():
					IP = JUMP
				# Let the IP += 1 happen, so we skip the lable
			elif inst == "stack-size":
				_push(len(stack))
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
				if trace_indent:
					trace -= 1
				IP = _r_pop()
				continue
			elif inst == "true":
				CODE[IP] = ["LIT", true]
				continue
			elif inst == "false":
				CODE[IP] = ["LIT", false]
				continue
			elif inst == "do-block":
				_r_push(IP+1)
				if trace_indent:
					trace += 1
				var lbl = _pop_special(lblSymb)
				IP = lbl[lblSymb]
				continue
			elif intPat.search(inst):
				CODE[IP] = ["LIT", int(inst)]
				continue
			elif floatPat.search(inst):
				CODE[IP] = ["LIT", float(inst)]
				continue
			elif inst in dict:
				CODE[IP] = ["CALL", dict[inst][lblSymb], inst]
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
				if trace_indent:
					trace+=1
				_r_push(IP+1)
				IP = inst[1]
				continue
			elif inst[0] == "U-PUSH":
				_u_push(_pop())
			elif inst[0] == "U-POP":
				_push(_u_pop())
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
			else:
				stop = true
				print(str("Unable to execute inst ", CODE[IP], " at ", IP))
				push_error(str("Unable to execute inst ", CODE[IP], " at ", IP))
				_push(inst)
				break
		IP += 1
	if not stop:
		emit_signal("script_end")
