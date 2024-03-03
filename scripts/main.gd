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
		"g: " + str(ch.score_g) + "\n"
	)

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
	for ch in next:
		pool.add(ch)
	pool.sort()
	
	if key == "discard":
		if len(pool.chromosomes) > data.n:
			pool.chromosomes.resize(data.n)
			pool.i = clamp(pool.i, 1, data.n)
			var t = Time.get_unix_time_from_system()
			var file = FileAccess.open("res://saves/pools/"+str(t), FileAccess.WRITE)
			file.store_string(JSON.stringify(pool.to_dict(), "	"))
	on_i_changed()
	print("done")

