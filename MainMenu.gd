extends Control

signal picked(name)

func _ready():
	pass

func _on_StartGameBtn_pressed():
	emit_signal("picked", "new-game")
