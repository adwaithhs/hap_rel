extends RefCounted

class_name Arc

const TOL = Global.TOL

const OUT_IN = Global.OUT_IN
const IN_IN = Global.IN_IN
const IN_OUT = Global.IN_OUT

var center:= Vector2()
var v1:= Vector2()
var v2:= Vector2()
var dir:= 1

func _init(center: Vector2, v1: Vector2, v2: Vector2, dir:=1):
	self.center = center
	self.v1 = v1
	self.v2 = v2
	self.dir = dir

func print():
	print({
		"c": center,
		"v1": v1,
		"v2": v2,
		"dir": dir,
	})

func split(center: Vector2, radius:float, i: int) -> Array:
	var v = center-self.center
	var d = v.length()
	v = v.normalized()
	if d <= TOL:
		return []
	if d >= 2*radius - TOL:
		return []
	var th = acos(d / 2 / radius)
	
	var b1 = v.rotated(+th).angle()
	var b2 = v.rotated(-th).angle()
	
	var ret = []
	if is_inside(b1):
		ret.append(PointData.new(self.center + radius * v.rotated(+th), i, center, OUT_IN))
	if is_inside(b2):
		ret.append(PointData.new(self.center + radius * v.rotated(-th), i, center, IN_OUT))
	
	return ret

func is_inside(b: float):
	var a1 = (v1 - center).angle()
	var a2 = (v2 - center).angle()
	if a2 < a1:
		return b > a1 or b < a2
	else:
		return b > a1 and b < a2
