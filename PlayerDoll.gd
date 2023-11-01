extends Sprite


var coord = Vector2(0,0)

export (NodePath) var tilemap

var map: TileMap

func _ready():
	map = get_node(tilemap)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var move_tween

func move_to(pos: Vector2):
	print("pos", coord)
	if is_instance_valid(move_tween) && move_tween.is_valid():
		return
	move_tween = create_tween()
	var curr_pos = map.map_to_world(coord)
	var des_pos = map.map_to_world(coord+pos)
	print("curr", curr_pos, "dest", des_pos)
	
	var midpoint = ((curr_pos + des_pos) / 2) + Vector2.UP * 8
	
	move_tween.tween_property(self, "position:x", midpoint.x, 0.25)
	move_tween.parallel().tween_property(self, "position:y", midpoint.y ,0.25).set_trans(Tween.TRANS_CIRC)
	
	move_tween.tween_property(self, "position:x", des_pos.x, 0.25)
	move_tween.parallel().tween_property(self, "position:y", des_pos.y, 0.25).set_trans(Tween.TRANS_CIRC)
	move_tween.tween_callback(self, "set", ["coord", pos+coord])
