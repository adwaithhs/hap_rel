extends RefCounted

class_name Edge

const TOL = Global.TOL

const OUT_IN = Global.OUT_IN
const IN_IN = Global.IN_IN
const IN_OUT = Global.IN_OUT

var v1:= Vector2()
var v2:= Vector2()

func _init(v1: Vector2, v2: Vector2):
	self.v1 = v1
	self.v2 = v2

func print():
	print({
		"v1": v1,
		"v2": v2,
	})

func split(center: Vector2, radius: float, i: int) -> Array:
	var normal = (-(v1 - v2).orthogonal()).normalized()
	var c_line = v1.dot(normal)
	var c_circ = center.dot(normal)
	var d = abs(c_line-c_circ)
	if c_circ >= c_line + radius - TOL:
		return [] # outside
	if c_circ <= c_line - radius - TOL:
		return [] # strictly inside
	var th = acos((c_circ - c_line) / radius)
	var u1 = center + radius * (-normal).rotated(+th)
	var u2 = center + radius * (-normal).rotated(-th)
	
	var pds = []
	
	if (u1-u2).length() < TOL:
		var u = center - radius * normal
		pds = [PointData.new(u, i, center, IN_IN)]
	else:
		pds = [
			PointData.new(u1, i, center, IN_OUT),
			PointData.new(u2, i, center, OUT_IN),
		]
	var ret:= []
	for pd in pds:
		var u = pd.p
		if (
			(v2 - v1).dot(u - v1) >= -TOL and
			(v1 - v2).dot(u - v2) >= -TOL
		):
			ret.append(pd)
	return ret
