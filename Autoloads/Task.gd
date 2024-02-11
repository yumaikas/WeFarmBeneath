extends Node

# Will be an Autoload

const default = {}

func case(task, arms):
    return TaskCase.new(task, arms)

func all(name, tasks):
	return TaskAll.new(name, tasks)

func do(name, tasks):
    return TaskDo.new(name, tasks)

func tween_continue(tween):
    return null

class TaskTween:

    signal continue(name, data)

    func _init(name, tween):
        pass


class TaskCase:
    signal continue(name, data)

    var _task
    var _arms

    func _init(task, arms):
        _task = task
        _arms = arms
        _task.connect("continue", self, "_do_case")
    
    func start():
        _task.start()

    func _do_case(name, _data):
        if _arms.has(name):
            var t = _arms[name]
            t.connect("continue", self, "done")
            t.start()
        elif _arms.has(default):
            var t = _arms[default]
            t.connect("continue", self, "done")
            t.start()
        else:
            print(name, " failed to match any cases ")

    func done(name, data):
        emit_signal("continue", name, data)


class TaskDo:

    var result = null
    var tname
    var task_def = []
    var tasks = []
    var active = false

    signal continue(name, data)

    func _init(name, subtasks):
        tname = name
        task_def = subtasks

    func start():
        if active:
            assert(false, "Trying to re-start task sequence")

        tasks = task_def.duplicate()
        var first_task = tasks.first()

        if first_task:
            first_task.connect("continue", self, "done", [], CONNECT_ONESHOT)
        else:
            emit_signal("continue", tname, tasks)

    func done(_name, data):
        result = data
        tasks.pop_front()
        if tasks.size() <= 0:
            emit_signal("continue", tname, result)
            active = false
        else:
            var head = tasks.first()
            head.connect("continue", self, "done", [], CONNECT_ONESHOT)
            head.start()

class TaskAll:
    signal continue(name, data)

    var count = 0
    var tname
    var results = []
    var tasks = []
	
    func start():
        for t in tasks:
            t.connect("continue", self, "done", [t])
            t.start()

    func _init(name, subtasks):
        tname = name
        tasks = subtasks
        count = tasks.size()
        results.resize(tasks.size())

    func _done(name, data, t):
        var idx = tasks.find(t)
        results[idx] = [name, data]
        count -= 1
        
        if count <= 0:
            emit_signal("continue", name, results)
        
        
