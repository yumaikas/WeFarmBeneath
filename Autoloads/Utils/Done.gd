extends Node

signal added_waiter()

var waiting_objects = []
var status = ""

func one(result = null):
    var waiter = DoneObj.new(result)
    add_child(waiter)
    return waiter

class DoneObj extends Node:
    signal completed(result)
    var result
    func _init(toReturn):
        result = toReturn
        call_deferred("emit_signal", "completed", result)
        queue_free()
