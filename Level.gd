extends Node2D

onready var playerDoll = $Level/Player

onready var player = Player.new(playerDoll)
onready var flor = Game.Floor.new(Rect2(0,0,4,4))

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("up"):
		player.move(Vector2(0, -1), flor)
	if Input.is_action_just_pressed("down"):
		player.move(Vector2(0, 1), flor)
	if Input.is_action_just_pressed("left"):
		player.move(Vector2(-1, 0), flor)
	if Input.is_action_just_pressed("right"):
		player.move(Vector2(1, 0), flor)
