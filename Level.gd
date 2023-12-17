extends Node2D

onready var playerDoll = $Level/PlayerOffset/Player

onready var flor = GameFloor.new(Rect2(0,0,4,4))
onready var map = $Level/Floor
onready var player = Player.new(playerDoll, Inventory)

var gameState: Game.GameObj

func _ready():
	gameState = Game.setup(self, player)
	var _junk = gameState.connect("game_sync", self, "_on_game_sync")
	Inventory.setup(null)


func _process(_delta):
	if Input.is_action_just_pressed("up"):
		gameState.do_event("move_player", {"dir": Vector2(0, -1)})
	if Input.is_action_just_pressed("down"):
		gameState.do_event("move_player", {"dir": Vector2(0, 1)})
	if Input.is_action_just_pressed("left"):
		gameState.do_event("move_player", {"dir": Vector2(-1, 0)})
	if Input.is_action_just_pressed("right"):
		gameState.do_event("move_player", {"dir": Vector2(1, 0)})

onready var inventoryDesc: RichTextLabel = $UI/Bag/Descriptions

func _on_game_sync(_game: Game.GameObj):
	var _junk = inventoryDesc.parse_bbcode((Inventory.bbcode_desc()))

func _on_shuffle_pressed():
	gameState.do_event("shuffle_current_floor", {"itemFactory": self})

var coinDollScn = preload("res://items/CoinDoll.tscn")

func makeCoinDoll(color):
	var coinDoll = coinDollScn.instance()
	coinDoll.setup(map, color)
	$Level/PlayerOffset.add_child(coinDoll)
	coinDoll.set_pos_to(Vector2(0, 0))
	coinDoll.hide()
	return coinDoll
