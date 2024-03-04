
@tool

extends Node2D


func _draw():
	print("ok")
	var c = Color.RED
	c.a = 0.5
	draw_circle(Vector2(), 0.6*150, c)
