class_name Proxy
extends Reference

var wrappedObj
func _init(wrapped):
    wrappedObj = wrapped

func wait(method: String, args = null):
    if args == null:
        args = []
    if is_instance_valid(wrappedObj):
        var ret = wrappedObj.callv(method, args)
        if ret is GDScriptFunctionState:
            return ret
        else: 
            printerr("Waited on invalid instance", wrappedObj)
            return D.one(ret)
    else:
        return D.one()
        