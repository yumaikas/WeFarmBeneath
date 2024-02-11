
# ActionButton.gd
func _ready():
func _process(delta):
func _do_pressed():
func _do_released():


# Fn.gd
class_name Fn
func _init(instance, method, bound_args = null):
func exec(args: Array):


# Game.gd
class_name Game
static func setup(itemFactory, player):
class GameObj extends Reference:
	func _ready():
		pass # Replace with function body.
	func _init(start_levels: Array):
	func do_event(type: String, data: Dictionary):
	func turn_events(type: String, data: Dictionary):
	func shuffle_floor_items(itemFactory, f: GameFloor):
class Mob extends Reference:
	func _init(mob_logic):
	func tick(amt: int, flor: GameFloor):


# ItemType.gd
class_name ItemType
static func create(id: String, display_name: String):
static func sort(a: ItemTypeData, b: ItemTypeData):
class ItemTypeData:
	func _init(id: String, display_name: String):


# Level.gd
func _ready():
func _process(_delta):
func _on_game_sync(_game: Game.GameObj):
func _on_shuffle_pressed():
func makeCoinDoll(color):


# MainMenu.gd
func _ready():
	pass # Replace with function body.
func _on_StartGameBtn_pressed():


# Player.gd
class_name Player
func _init(frame, inventoryToUse: Inventory):
func tick(amt: int, flor: GameFloor):
func move(dir: Vector2, flor: GameFloor):


# PlayerDoll.gd
func _ready():
func wiggle():
func move_to(pos: Vector2):


# plants.gd
class_name Plant
func harvest():
func tick(amt: int, flor: GameFloor):
static func Wheat(tile_ids: Dictionary, inventory: Inventory, doll):


# Inventory.gd
func _init():
func setup(inventory_doll):
func add(item_type: ItemType.ItemTypeData, amt: int):
func has(item_type):
func has_room(_item_type, _amount):
func bbcode_desc():
func take(item_type: ItemType.ItemTypeData, amt: int):


# Task.gd
func case(task, arms):
func all(name, tasks):
func do(name, tasks):
func tween_continue(tween):
class TaskTween:
    func _init(name, tween):
class TaskCase:
    func _init(task, arms):
    func start():
    func _do_case(name, _data):
    func done(name, data):
class TaskDo:
    func _init(name, subtasks):
    func start():
    func done(_name, data):
class TaskAll:
    func start():
    func _init(name, subtasks):
    func _done(name, data, t):


# Util.gd
func _init():
func dX(x: int):
func R(minValue, maxValue):
func rand_pos(xrange: ValueRange, yrange: ValueRange ):
func randi_range(low: int, high: int):


# GameFloor.gd
class_name GameFloor
func _init(bounds: Rect2):
func show():
func hide():
func is_walkable(pos: Vector2):
func get_things_at(pos: Vector2):
func tick_all(amt: int, a: Array):
func reap_all(a: Array):
func tick(amt: int):
func tiles() -> Array:


# CoinDoll.gd
func _ready():
	pass # Replace with function body.
func setup(map, color):
func bind_to(other):
func _process(_delta):
func set_color(to):
func bounce():
func set_pos_to(pos: Vector2):


# coins.gd
class_name Coin
static func copper(frame, amt):
static func silver(frame, amt):
static func gold(frame, amt):
class CoinObj extends Reference:
	func _init(frame, type, quantity):
	func kill():
	func walked_over(_player, inventory: Inventory):
	func tick(amt: int, _flor: GameFloor):


# CoroProxy.gd
class_name Proxy
func _init(wrapped):
func wait(method: String, args = null):


# Done.gd
func one(result = null):
class DoneObj extends Node:
    func _init(toReturn):


# ValueRange.gd
class_name ValueRange
func _init(minValue, maxValue):
func roll():

