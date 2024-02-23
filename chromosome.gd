extends RefCounted

class_name Chromosome

var genes: Array[Gene]= []
var score = null

static func random(radius, n_genes):
	var child = Chromosome.new()
	for i in n_genes:
		var g = Gene.new()
		g.center.x = (1+radius)*randz()
		g.center.y = (1+radius)*randz()
		g.weight = randfn(0.0, 1.0)
		child.genes.append(g)
	return child

func mutate(radius, p, q, dx, dw):
	var child = Chromosome.new()
	for gene in genes:
		var g = Gene.new()
		g.center.x = wrapf(
			g.center.x + dx*randz(),
			-1-radius,
			+1+radius,
		)
		g.center.y = wrapf(
			g.center.y + dx*randz(),
			-1-radius,
			+1+radius,
		)
		g.weight += randfn(0.0, dw)
		g.weight /= sqrt(1.0 + dw*dw)
		child.genes.append(g)
	return child

func cross(ch1):
	var child = Chromosome.new()
	var gs1 = self.genes
	var gs2 = ch1.genes
	if len(gs1) < len(gs2):
		var temp = gs1
		gs1 = gs2
		gs2 = temp
	gs1 = gs1.duplicate()
	gs1.shuffle()
	for i in len(gs2):
		if randf() < 0.5:
			child.genes.append(gs1[i])
		else:
			child.genes.append(gs2[i])
	for i in range(len(gs2), len(gs1)):
		if randf() < 0.5:
			child.genes.append(gs1[i])
	return child

static func randz():
	return 2*randf() - 1

func dissect():
	genes.sort_custom(func(a, b): return a.weight > b.weight)
	print(genes[0].weight)
	


