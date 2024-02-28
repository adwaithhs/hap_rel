extends RefCounted

class_name Chromosome

var genes: Array[Gene]= []
var score = null

static func random(radius, n_genes) -> Chromosome:
	var child = Chromosome.new()
	for i in n_genes:
		var g = Gene.new()
		g.center.x = (1+radius)*randz()
		g.center.y = (1+radius)*randz()
		g.weight = randfn(0.0, 1.0)
		child.genes.append(g)
	return child

func mutate(radius, p, q, dx, dw) -> Chromosome:
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

func cross(ch1) -> Chromosome:
	var child = Chromosome.new()
	var gs1 = genes
	var gs2 = ch1.genes
	if len(gs1) < len(gs2):
		var temp = gs1
		gs1 = gs2
		gs2 = temp
	gs1 = gs1.duplicate()
	gs1.shuffle()
	for i in len(gs2):
		if randf() < 0.5:
			child.genes.append(gs1[i].copy())
		else:
			child.genes.append(gs2[i].copy())
	for i in range(len(gs2), len(gs1)):
		if randf() < 0.5:
			child.genes.append(gs1[i].copy())
	return child

static func randz():
	return 2*randf() - 1

var tree_root = null
var subsets
var matrix

func dissect(radius):
	genes.sort_custom(func(a, b): return a.weight > b.weight)
	print(genes[0].weight)
	var n = floor(2.0 / radius)
	matrix = []
	matrix.resize(n+2)
	for i in n+2:
		var l = []
		l.resize(n+2)
		for j in n+2:
			l[j] = GridNode.new()
			l[j].pos = Vector2i(i, j)
		matrix[i] = l
	for g in genes:
		var i = get_index(n, g.center.x)
		var j = get_index(n, g.center.y)
		matrix[i][j].genes.append(g)
		g.pos = Vector2i(i, j)
	for i in range(1, n+1):
		for j in range(1, n+1):
			matrix[i][j].init(n)
	for g in genes:
		var nbhood: Array[GridNode]= []
		for i in range(
			clampi(g.pos.x - 1, 1, n),
			clampi(g.pos.x + 1, 1, n) + 1
		):
			for j in range(
				clampi(g.pos.y - 1, 1, n),
				clampi(g.pos.y + 1, 1, n) + 1,
			):
				nbhood.append(matrix[i][j])
		var nh = []
		for node in nbhood:
			if true: #intersect(node, gene) != phi:
				nh.append(node)
		nbhood = nh
		for node in nbhood:
			if node.covered:
				continue
			node.intersect(g, radius)
		for node in nbhood:
			node.newsubs = []

func get_index(n: int, x: float):
	var i = floor((x + 1.0) / 2 * n) + 1
	return clamp(i, 0, n+1)
