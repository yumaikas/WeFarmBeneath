class_name Player
extends Reference

var pos = Vector2(0,0)

var doll

func _init(frame):
	doll = frame

func tick(amt: int, flor: Game.Floor):
	pass

func move(dir: Vector2, flor: Game.Floor):
	if flor.is_walkable(pos + dir):
		pos = pos + dir
		tick(1, flor)
		doll.move_to(pos+dir)
