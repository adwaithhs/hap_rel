extends RefCounted

class_name Test

func run():
	#test1()
	#test2()
	var radius = 0.5
	seed(162)
	var ch = Chromosome.random(radius, 25)
	ch.dissect(radius)
	
	pass

const OUT_IN = +1
const IN_IN = 0
const IN_OUT = -1

func test_inside():
	for dirs in [
		[IN_IN, IN_IN],
		[OUT_IN, IN_OUT, OUT_IN, IN_IN, IN_IN, IN_OUT],
		[],
		[OUT_IN, IN_IN],
		[IN_OUT, IN_IN],
		[OUT_IN, IN_OUT, IN_IN, IN_IN, IN_OUT],
		[OUT_IN, IN_OUT, OUT_IN, IN_IN, IN_IN],
		[OUT_IN, IN_OUT, IN_OUT, OUT_IN, IN_IN, IN_IN, IN_OUT],
		[IN_OUT, OUT_IN, IN_IN, IN_IN, IN_OUT],
		
	]:
		var ps = []
		for dir in dirs:
			ps.append({"dir":dir})
		
		print(GridNode.is_fine(ps))

func test_area():
	for n in 10:
		var ps = []
		for i in n:
			ps.append(Vector2.RIGHT.rotated(i*2*PI/n))
		
		var a_true = n*sin(2*PI/n)/2
		
		if len(ps) % 2 != 0:
			ps.append(ps[0])
		var a = 0.0
		for i in range(0, len(ps), 2):
			var i1 = wrap(i+1, 0, len(ps))
			var i2 = wrap(i+2, 0, len(ps))
			a += ps[i1].x*(ps[i2].y - ps[i].y) + ps[i1].y *(ps[i].x - ps[i2].x)
		a /= 2
		print(a, " ", a_true)

func test_d2():
	var ch = Chromosome.new()
	var g
	g = Gene.new()
	g.center = Vector2(1.462082, 0.915322)
	ch.genes.append(g)
	g = Gene.new()
	g.center = Vector2(0.707108, 0.337498)
	ch.genes.append(g)
	var comp1 = [
		Arc.from({ "c": Vector2(1.462082, 0.915322), "v1": Vector2(0.969305, 1), "v2": Vector2(1, 0.724325), "dir": 1 }),
		Edge.from({ "v1": Vector2(1, 0.724325), "v2": Vector2(1, 1) }),
		Edge.from({ "v1": Vector2(1, 1), "v2": Vector2(0.969305, 1) }),
	]

	var comp2 = [
		Arc.from({ "c": Vector2(1.462082, 0.915322), "v1": Vector2(1, 0.724325), "v2": Vector2(0.969305, 1), "dir": -1 }),
		Edge.from({ "v1": Vector2(0.969305, 1), "v2": Vector2(0.5, 1) }),
		Edge.from({ "v1": Vector2(0.5, 1), "v2": Vector2(0.5, 0.5) }),
		Edge.from({ "v1": Vector2(0.5, 0.5), "v2": Vector2(1, 0.5) }),
		Edge.from({ "v1": Vector2(1, 0.5), "v2": Vector2(1, 0.724325) }),
	]
	var node = GridNode.new()
	var s
	s = Subset.new()
	s.comps = [comp1]
	node.subsets.append(s)
	s = Subset.new()
	s.comps = [comp2]
	node.subsets.append(s)
	
	node.slice_test(ch.genes[1], 0.5)
	
	

func test2(n:=100, m:=3, radius:=0.6):
	# 162, 25, 0.5
	for i in n:
		seed(i)
		var ch = Chromosome.random(radius, m)
		print(i)
		ch.dissect(radius)
		



func test1():
	var ch = Chromosome.new()
	var g
	var R = 0.5
	g = Gene.new()
	g.center = Vector2(0.0, 0.0)
	ch.genes.append(g)
	
	g = Gene.new()
	g.center = Vector2(R, 0.0)
	ch.genes.append(g)
	
	g = Gene.new()
	g.center = Vector2(0.0, R)
	ch.genes.append(g)
	
	g = Gene.new()
	g.center = Vector2(R, R)
	ch.genes.append(g)
	
	ch.dissect(R)
