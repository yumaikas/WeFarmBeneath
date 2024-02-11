class_name Coin
extends Reference

static func copper(frame, amt):
	return CoinObj.new(frame, Inventory.COPPER, amt)

static func silver(frame, amt):
	return CoinObj.new(frame, Inventory.SILVER, amt)

static func gold(frame, amt):
	return CoinObj.new(frame, Inventory.GOLD, amt)

class CoinObj extends Reference:
	var doll
	var item_type
	var amount
	var live = true

	func _init(frame, type, quantity):
		doll = frame
		doll.bind_to(self)
		doll.amt = quantity
		item_type = type
		amount = quantity

	func kill():
		live = false
		
	func walked_over(_player, inventory: Inventory):
		print("Coin Walked Over!")
		if not live:
			print("Coin is dead!")
			return D.one()
		if inventory.has_room(item_type, amount):
			inventory.add(item_type, amount)
			kill()
			doll.queue_free()
		return D.one()

	func tick(amt: int, _flor: GameFloor):
		for a in amt:
			if Util.randi_range(0, 3) == 2:
				doll.bounce()


