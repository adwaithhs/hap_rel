extends Control

@onready
var actions_menu = $Actions
@onready
var figure = $Figure
@onready
var index_input = $MarginContainer/CenterContainer/IndexInput
@onready
var label = $PanelContainer/MarginContainer/Label

var pool:= Pool.new()

func _ready():
	pool.radius = 0.6
	figure.pool = pool
	index_input.pool = pool
	actions_menu.action_oked.connect(on_action)
	index_input.i_changed.connect(on_i_changed)
	
	var f = FileAccess.open("res://saves/pools/"+"D1709530927.23471", FileAccess.READ)
	pool = Pool.from_dict(JSON.parse_string(f.get_as_text()))
	
	figure.pool = pool
	index_input.pool = pool
	var s = randi_range(0, 1000)
	print("seed: ", s)
	seed(s)
	#var radius = 0.5
	#seed(162)
	#var ch = Chromosome.random(radius, 25)
	#ch.dissect(radius)
	#pool.add(ch)

func on_i_changed():
	figure.queue_redraw()
	label.text = ""
	if pool.i < 1: return
	if pool.i > len(pool.chromosomes): return
	var ch = pool.chromosomes[pool.i-1]
	label.text = (
		"score: " + str(ch.score) + "\n" +
		"r: " + str(ch.score_r) + "\n" +
		"g: " + str(ch.cost_g) + "\n" +
		"d: " + str(ch.cost_d) + "\n" +
		"distn:\n" + JSON.stringify(ch.distn, " ") + "\n"
	)

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_H:
			actions_menu.visible = not actions_menu.visible
			index_input.visible = not index_input.visible
			label.visible = not label.visible
		if event.keycode == KEY_P:
			if pool.i < 1: return
			if pool.i > len(pool.chromosomes): return
			var ch = pool.chromosomes[pool.i-1]
			print((
				"score: " + str(ch.score) + "\n" +
				"r: " + str(ch.score_r) + "\n" +
				"g: " + str(ch.cost_g) + "\n" +
				"d: " + str(ch.cost_d) + "\n" +
				"distn:\n" + str(ch.distn) + "\n"
			))

func on_action(key, data):
	print(key)
	var next = []
	if key == "random":
		for i in data.n:
			var ch = Chromosome.random(pool.radius, data.m)
			next.append(ch)
	if key == "mutate":
		for i in data.n:
			var ch1: Chromosome= pool.chromosomes.pick_random()
			var ch = ch1.mutate(pool.radius, data.p, data.q, data.dx, data.dw)
			next.append(ch)
	if key == "cross":
		for i in data.n:
			var j = randi_range(0, len(pool.chromosomes) - 1)
			var k = randi_range(0, len(pool.chromosomes) - 2)
			if k >= j:
				k += 1
			var ch1: Chromosome= pool.chromosomes[j]
			var ch2: Chromosome= pool.chromosomes[k]
			var ch = ch1.cross(ch2)
			next.append(ch)
	if key == "discard":
		if len(pool.chromosomes) > data.n:
			pool.chromosomes.resize(data.n)
			pool.i = clamp(pool.i, 1, data.n)
			var t = Time.get_unix_time_from_system()
			var file = FileAccess.open("res://saves/pools/D"+str(t), FileAccess.WRITE)
			file.store_string(JSON.stringify(pool.to_dict(), "	"))
	#if key == "rescore":
		#for ch in pool.chromosomes:
			#pool.mult_g = data.mult_g
			#pool.mult_d = data.mult_d
			#ch.calc_score(pool.radius, true, 0.9, data.mult_g, data.mult_d)
		#pool.sort()
	if key == "hex_init":
		var child = Chromosome.new()
		for p in Global.hex:
			var g = Gene.new()
			g.center = p
			g.weight = randfn(0.0, 1.0)
			child.genes.append(g)
		for p in Global.hex:
			var g = Gene.new()
			g.center = Vector2(p.y, p.x)
			g.weight = randfn(0.0, 1.0)
			child.genes.append(g)
		next.append(child)
	
	
	
	if len(next):
		for ch in next:
			pool.add(ch)
		pool.sort()
	
	on_i_changed()
	print("done")

