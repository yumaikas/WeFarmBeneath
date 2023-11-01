class_name Fn
extends Reference

var instance
var method
var bound_args: Array

func _init(instance, method, bound_args = null):
	self.instance = instance
	self.method = method
	if bound_args != null:
		self.bound_args = bound_args

func exec(args: Array):
	if is_instance_valid(instance):
		var calling_with = bound_args.duplicate()
		calling_with.append_array(args)
		instance.callv(method, calling_with)
	else:
		var debug_args = []
		var calling_with = bound_args.duplicate()
		calling_with.append_array(args)
		
		for a in calling_with:
			debug_args.push(str(a))
		printerr(str("Invalid call", method, ", ".join(PoolStringArray(debug_args))))
		
