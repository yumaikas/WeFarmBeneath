extends Node

var die

func _init():
	die = RandomNumberGenerator.new()
	die.randomize()

func dX(x: int):
	return die.randi_range(1, x)


func R(minValue, maxValue):
	return ValueRange.new(minValue, maxValue)

func rand_pos(xrange: ValueRange, yrange: ValueRange ):
	return Vector2(
		xrange.roll(),
		yrange.roll()
	)

func randi_range(low: int, high: int):
	return die.randi_range(low, high)


