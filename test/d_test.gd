extends Node2D

const WIDTH = 4

@export
var size:= 150

var radius:= 0.6
var ch:= Chromosome.new()
var mode:= 0
var subsets:= []
var progress = -1

func _ready():
	pass

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			mode = 0
			progress = -1
			subsets = []
			ch = Chromosome.new()
			queue_redraw()
		if event.keycode == KEY_Z:
			if mode == 2:
				progress = -1
				subsets = []
			mode = 0
			queue_redraw()
		if event.keycode == KEY_A:
			if mode == 0:
				mode = 1
		if event.keycode == KEY_X:
			mode = 2
			test_ch_step()
			queue_redraw()
		if event.keycode == KEY_Z:
			pass
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			var v = (event.position - position) / size
			if mode == 1:
				var g = Gene.new()
				g.center = v
				g.weight = -len(ch.genes)
				ch.genes.append(g)
				queue_redraw()
				mode = 0
				

func _draw():
	draw_square(size)
	if mode == 0 or mode == 1 or progress >= len(ch.genes):
		for g in ch.genes:
			if mode != 2 or g.active:
				my_draw_circle(g.center*size, radius*size)
		return
	for h in progress:
		var g = ch.genes[h]
		if g.active:
			my_draw_circle(g.center*size, radius*size)
	if mode == 2:
		for s in subsets:
			print("subset")
			for comp in s.comps:
				print("comp")
				for e in comp:
					e.print()
					if e is Edge:
						draw_line(e.v1*size, e.v2*size, Color.GREEN, WIDTH/2)
					if e is Arc:
						var a1 = (e.v1 - e.center).angle()
						var a2 = (e.v2 - e.center).angle()
						if e.dir > 0:
							my_draw_arc(e.center*size, radius*size, e.v1*size, e.v2*size)
						else:
							my_draw_arc(e.center*size, radius*size, e.v2*size, e.v1*size)
					if e is Circle:
						my_draw_circle(e.center*size, radius*size, Color.GREEN)

func my_draw_arc(center: Vector2, radius: float, v1: Vector2, v2: Vector2, color:= Color.GREEN, width:= WIDTH):
	v1 = v1 - center
	v2 = v2 - center
	var th = v1.angle_to(v2)
	if th < 0:
		th+=2*PI
	var ps = []
	var n = 20
	for i in n+1:
		ps.append(center + v1.rotated(i*th/n))
	draw_polyline(ps, color, width)

func my_draw_circle(center: Vector2, radius: float, color:= Color.RED, width:= WIDTH):
	var ps = []
	var n = 20
	for i in n+1:
		ps.append(center + radius*Vector2.UP.rotated(2*PI*i/n))
	draw_polyline(ps, color, width)

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
	
func test_ch_step():
	if progress >= len(ch.genes):
		print("Done")
		progress = -1
		subsets = []
		return
	if progress == -1:
		ch.init_matrix(radius)
		progress+=1
		subsets = []
		return
	print("progress: ", progress)
	var g = ch.genes[progress]
	var nbhood = ch.get_nbhd(g)
	var needed = false
	for node in nbhood:
		needed = node.slice(g, radius)
	if needed:
		g.active = true
		for node in nbhood:
			node.subsets = node.newsubs
	for node in nbhood:
		node.newsubs = []
	progress+=1
	subsets = []


func get_idx(n: int, x: float):
	var i = floor((x + 1.0) / 2 * n) + 1
	return clamp(i, 0, n+1)
