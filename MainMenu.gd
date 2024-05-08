extends Node2D

func _ready():
	pass

func add(i, j):
	return i + j

func derp():
	print("D E R P")

func _on_StartGameBtn_pressed():
	get_tree().change_scene("res://LevelExperiment.tscn")
