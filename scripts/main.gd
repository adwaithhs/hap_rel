extends Control

@onready
var actions_menu = $Actions
@onready
var figure = $Figure

var pool:= Pool.new()

func _ready():
	pool.radius = 0.6
	figure.pool = pool
	figure.i = 1
	actions_menu.action_oked.connect(on_action)
	
	var radius = 0.5
	seed(162)
	var ch = Chromosome.random(radius, 25)
	ch.dissect(radius)
	get_tree().quit()
	pool.add(ch)


func fprint(x:float):
	print(x/2)

func on_action(key, data):
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
	figure.queue_redraw()

