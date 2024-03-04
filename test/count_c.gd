extends Panel



func _ready():
	var ps = []
	for child in get_children():
		var v = child.position / 150.0
		v.y = -v.y
		ps.append(v + Vector2(-1, 1))
	
	var s = "["
	for p in ps:
		s += "Vector2" + str(p) + ", "
	s+= "]"
	# print(s)

