class_name Game
extends Reference

	
static func setup(itemFactory, player):
	var pos_r = Util.R(0, 4)

	var f1 = GameFloor.new(Rect2(0,0, 4,4))
	for i in Util.dX(4):
		var amt = Util.R(1, 3)
		var doll = itemFactory.makeCoinDoll("copper")
		var pos = Util.rand_pos(pos_r, pos_r)
		doll.set_pos_to(pos)
		f1.dolls.append(doll)
		f1.items[pos] = Coin.copper(doll, amt.roll())

	var f2 = GameFloor.new(Rect2(0,0, 4,4))
	for i in Util.dX(2):
		var amt = Util.R(1, 2)
		var doll = itemFactory.makeCoinDoll("silver")
		var pos = Util.rand_pos(pos_r, pos_r)
		f2.dolls.append(doll)
		doll.set_pos_to(pos)
		f2.items[pos] = Coin.silver(doll, amt.roll())

	f1.show()
	f2.hide()
	
	var game = GameObj.new([f1, f2])
	game.level_idx = 0
	game._player = player
	return game

class GameObj extends Reference:
	const done = "completed"
	var levels = []
	var level_idx: int
	var _player
	signal game_sync(me)

	# Called when the node enters the scene tree for the first time.
	func _ready():
		pass # Replace with function body.

	func _init(start_levels: Array):
		levels = start_levels

	var doing_event = false
	var event_queue = []
	func do_event(type: String, data: Dictionary):
		if doing_event:
			event_queue.append([type, data])
			return

		event_queue.append([type, data])
		while event_queue.size() > 0:
			var evt = event_queue.pop_front()
			var etype = evt[0]
			var edata = evt[1]
			yield(turn_events(etype, edata), done)

	func turn_events(type: String, data: Dictionary):
		if doing_event:
			return D.one()

		doing_event = true
		if type == "tick":
			for l in levels:
				yield(l.tick(data.amt), done)
		if type == "shuffle_current_floor":
			shuffle_floor_items(data["itemFactory"], levels[level_idx])
		if type == "move_player":
			yield(_player.move(data["dir"], levels[level_idx]), done)
			for l in levels:
				yield(l.tick(1), done)
				print("HIT HERE")

		emit_signal("game_sync", self)
		doing_event = false
		return D.one()

	func shuffle_floor_items(itemFactory, f: GameFloor):
		for i in f.items.values():
			i.kill()
			var rmidx = f.dolls.find(i.doll)
			if rmidx != -1:
				f.dolls.remove(rmidx)

		f.reap_all([f.items])

		var pos_r = Util.R(0, 4)
		var amt = Util.R(1, 3)
		for i in Util.dX(4):
			var pos = Util.rand_pos(pos_r, pos_r)
			var item_roll = Util.dX(20)
			if not f.items.has(pos) and item_roll <= 18:
				var doll = itemFactory.makeCoinDoll("copper")
				doll.set_pos_to(pos)
				f.dolls.append(doll)
				f.items[pos] = Coin.copper(doll, amt.roll())
			elif not f.items.has(pos) and item_roll <= 19:
				var doll = itemFactory.makeCoinDoll("silver")
				doll.set_pos_to(pos)
				f.dolls.append(doll)
				f.items[pos] = Coin.silver(doll, amt.roll())
			elif not f.items.has(pos) and item_roll == 20:
				var doll = itemFactory.makeCoinDoll("gold")
				doll.set_pos_to(pos)
				f.dolls.append(doll)
				f.items[pos] = Coin.gold(doll, 1)
		f.show()

class Mob extends Reference:
	const done = "completed"
	var doll
	var logic
	
	func _init(mob_logic):
		self.logic = mob_logic
	
	func tick(amt: int, flor: GameFloor):
		yield(logic.tick(amt, flor, doll), done)

		
