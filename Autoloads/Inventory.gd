extends Node

var WHEAT = ItemType.create("plants/wheat", "wheat")

var AMMO_SHELLS = ItemType.create("ammo/shells", "shotgun shells")

var TOOL_SHOTGUN = ItemType.create("tools/shotgun", "shotgun")
var TOOL_PISTOL = ItemType.create("tools/pistol", "pistol")
var TOOL_PICKAXE = ItemType.create("tools/pickaxe", "pickaxe")
var TOOL_SCYTHE = ItemType.create("tools/scythe", "scythe")

var COPPER = ItemType.create("currency/a/copper", "copper")
var SILVER = ItemType.create("currency/b/silver", "silver")
var GOLD = ItemType.create("currency/c/gold", "gold")

var doll

var item_counts: Dictionary = {}

func _init():
	pass

func setup(inventory_doll):
	doll = inventory_doll

func add(item_type: ItemType.ItemTypeData, amt: int):
	item_counts[item_type] = item_counts.get(item_type, 0) + amt

func has(item_type):
	return item_counts.has(item_type)

func has_room(_item_type, _amount):
	return true

func bbcode_desc():
	var parts = PoolStringArray()
	var keys: Array = item_counts.keys()
	keys.sort_custom(ItemType, "sort")

	for k in keys:
		parts.append(k.display_name)
		parts.append(" - ")
		parts.append(str(item_counts[k]))
		parts.append("\n")

	return "".join(parts)

func take(item_type: ItemType.ItemTypeData, amt: int): 
	if item_counts.has(item_type):
		item_counts[item_type] = max(0, item_counts[item_type] - amt)
		if item_counts[item_type] == 0:
			var _j = item_counts.erase(item_type)
	
