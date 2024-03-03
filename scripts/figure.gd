extends Node2D

const WIDTH = 4

@export
var size:= 150

var pool: Pool

func _draw():
	draw_square(size)
	if pool == null:
		return
	var i = pool.i
	if not(i >= 1 and i <= len(pool.chromosomes)):
		return
	var ch : Chromosome= pool.chromosomes[i-1]
	for g in ch.genes:
		if g.active:
			my_draw_circle(g.center*size, pool.radius*size)

func my_draw_circle(center: Vector2, radius: float, color:= Color.RED):
	var ps = []
	var n = 100
	for i in n+1:
		ps.append(center + radius*Vector2.UP.rotated(2*PI*i/n))
	draw_polyline(ps, color, WIDTH)

func draw_square(a):
	var a00 = Vector2(-a, -a)
	var a10 = Vector2(a, -a)
	var a11 = Vector2(a, a)
	var a01 = Vector2(-a, a)
	for v in [
		[a00, a10],
		[a10, a11],
		[a11, a01],
		[a01, a00],
	]:
		draw_line(v[0], v[1], Color.BLUE, WIDTH)
	
	draw_line(Vector2(2*a, 0), Vector2(-2*a, 0), Color.BLUE, WIDTH/2)
	draw_line(Vector2(0, 2*a), Vector2(0, -2*a), Color.BLUE, WIDTH/2)
	
