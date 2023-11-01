class_name Inventory
extends Reference

var WHEAT = ItemType.create("plants/wheat", "wheat")

var AMMO_SHELLS = ItemType.create("ammo/shells", "shotgun shells")

var TOOL_SHOTGUN = ItemType.create("tools/shotgun", "shotgun")
var TOOL_PISTOL = ItemType.create("tools/pistol", "pistol")
var TOOL_PICKAXE = ItemType.create("tools/pickaxe", "pickaxe")
var TOOL_SCYTHE = ItemType.create("tools/scythe", "scythe")

var COPPER = ItemType.create("currency/copper", "copper")
var SILVER = ItemType.create("currency/silver", "silver")
var GOLD = ItemType.create("currency/gold", "gold")


var doll

var item_counts: Dictionary = {}

func _init(inventory_doll):
	doll = inventory_doll

func add(item_type: ItemType, amt: int):
	item_counts[item_type] = item_counts.get(item_type, 0) + amt

func has(item_type):
	return item_counts.has(item_type)

func take(item_type: ItemType, amt: int): 
	if item_counts.has(item_type):
		item_counts[item_type] = max(0, item_counts[item_type] - amt)
		if item_counts[item_type] == 0:
			item_counts.erase(item_type)
	
