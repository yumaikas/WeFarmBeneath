extends Node


# Called when the node enters the scene tree for the first time.

var die 

func _ready():
	randomize()
	die = RandomNumberGenerator.new()

func randi_range(l, h):
	return die.randi_range(l, h)

