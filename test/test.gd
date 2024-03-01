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
