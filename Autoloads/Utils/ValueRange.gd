class_name ValueRange

var _min
var _max
func _init(minValue, maxValue):
    _min = minValue
    _max = maxValue

func roll():
    return Util.randi_range(_min, _max)