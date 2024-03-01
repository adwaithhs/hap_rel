extends RefCounted

class_name Gene

var center:= Vector2()
var weight:= 0.0
var active:= false
var pos:= Vector2i()
var i:= -1

func copy():
	var g = Gene.new()
	g.center = center
	g.weight = weight
	return g

func print():
	print({
		"c": center,
		"w": weight,
	})
