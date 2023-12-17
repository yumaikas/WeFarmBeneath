extends Sprite

var coord = Vector2(0,0)

export (NodePath) var tilemap

var map: TileMap

func _ready():
	map = get_node(tilemap)

var move_tween
var moving = false

func wiggle():
	if moving:
		printerr("This should never happen in wiggle")
		return D.one()
	moving = true
	move_tween = create_tween()
	
	move_tween.tween_property(self, "rotation_degrees", rotation_degrees - 10, 0.125)
	move_tween.tween_property(self, "rotation_degrees", rotation_degrees + 10, 0.125)
	move_tween.tween_property(self, "rotation_degrees", rotation_degrees, 0.125) 
	yield(move_tween, "finished")
	moving = false

func move_to(pos: Vector2):
	if moving:
		printerr("This should never happen in move_to")
		return D.one()
	moving = true
	move_tween = create_tween()
	var curr_pos = map.map_to_world(coord, true)
	var des_pos = map.map_to_world(pos, true)
	
	var midpoint = ((curr_pos + des_pos) / 2) + Vector2(0, -4)
	
	move_tween.tween_property(self, "position:x", midpoint.x, 0.125)
	move_tween.parallel().tween_property(self, "position:y", midpoint.y , 0.125 / 2.0).set_trans(Tween.TRANS_CIRC)
	
	move_tween.tween_property(self, "position:x", des_pos.x, 0.125)
	move_tween.parallel().tween_property(self, "position:y", des_pos.y, 0.125 / 2.0).set_trans(Tween.TRANS_CIRC)
	move_tween.tween_callback(self, "set", ["coord", pos])
	yield(move_tween, "finished")
	moving = false
