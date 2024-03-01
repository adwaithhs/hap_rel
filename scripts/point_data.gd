extends RefCounted
class_name PointData

var p:= Vector2()
var i:= -1
var dir:= Global.IN_OUT
var angle:= 0.0

func _init(p: Vector2, i: int, center: Vector2, dir:=Global.IN_OUT):
	self.p = p
	self.i = i
	self.dir = dir
	self.angle = (p-center).angle()
