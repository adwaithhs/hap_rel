extends RefCounted

class_name Chromosome

var genes:= []
var score = null
var matrix
var n
var distn = {}

func to_dict():
	var gs = []
	for gene in genes:
		gs.append(gene.to_dict())
	return{
		"genes": gs,
		"distn": distn
	}

static func from_dict(d, radius:=0.6, mult_g:=0.01, mult_d:=1.0):
	var ch = Chromosome.new()
	ch.distn = d.distn
	for g in d.genes:
		ch.genes.append(Gene.from_dict(g))
	var rel = 0.9
	var gene_cost = 0
	for gene in ch.genes:
		if gene.active:
			gene_cost+=1
	var f = 1 - rel
	var total_f = 0

	for n in ch.distn:
		total_f += pow(f, int(n)) * float(ch.distn[n])
	
	var m = len(ch.genes)
	var k = 0
	var d_sum = 0.0
	for i in m:
		for j in i:
			var g1 = ch.genes[i]
			var g2 = ch.genes[j]
			if abs(g1.center.x) > 1.0: continue
			if abs(g1.center.y) > 1.0: continue
			if abs(g2.center.x) > 1.0: continue
			if abs(g2.center.y) > 1.0: continue
			var d1 = (g1.center - g2.center).length()
			d_sum += pow(0.1, d1/radius)
			k += 1
	
	ch.score_r = 1 - total_f / 4.0
	ch.cost_g = gene_cost * mult_g
	ch.cost_d = d_sum / k * mult_d
	ch.score = ch.score_r - ch.cost_g - ch.cost_d

	
	return ch

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
		var g = gene.copy()
		if randf() < p:
			g.center.x = wrapf(
				gene.center.x + dx*randz(),
				-1-radius,
				+1+radius,
			)
			g.center.y = wrapf(
				gene.center.y + dx*randz(),
				-1-radius,
				+1+radius,
			)
		if randf() < q:
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

var last_r = 0
var score_r = 0
var cost_g = 0
var cost_d = 0

func calc_score(radius: float, repeat:= false, rel:= 0.9, mult_g:=0.01, mult_d:=1.0):
	if score == null or repeat:
		if abs(last_r - radius) > Global.TOL:
			var ret = dissect(radius)
			if ret is String and ret == "error":
				return "error"
			last_r = radius
		var gene_cost = 0
		for gene in genes:
			if gene.active:
				gene_cost+=1
		var f = 1 - rel
		var total_f = 0
		distn = {}
		for l in matrix:
			for node in l:
				for sset in node.subsets:
					var n = len(sset.genes)
					if n not in distn:
						distn[n] = 0.0
					distn[n] += sset.get_area(radius)
					total_f += sset.get_fail(f) * sset.get_area(radius)
		
		var m = len(genes)
		var k = 0
		var d_sum = 0.0
		for i in m:
			for j in i:
				var g1 = genes[i]
				var g2 = genes[j]
				if abs(g1.center.x) > 1.0: continue
				if abs(g1.center.y) > 1.0: continue
				if abs(g2.center.x) > 1.0: continue
				if abs(g2.center.y) > 1.0: continue
				var d = (g1.center - g2.center).length()
				d_sum += pow(0.1, d/radius)
				k += 1
		
		score_r = 1 - total_f / 4.0
		cost_g = gene_cost * mult_g
		cost_d = d_sum / k * mult_d
		score = score_r - cost_g - cost_d

func init_matrix(radius: float):
	genes.sort_custom(func(a, b): return a.weight > b.weight)
	n = floor(2.0 / radius)
	matrix = []
	matrix.resize(n+2)
	for i in n+2:
		var l = []
		l.resize(n+2)
		for j in n+2:
			l[j] = GridNode.new()
			l[j].pos = Vector2i(i, j)
		matrix[i] = l
	for h in len(genes):
		var g = genes[h]
		var i = get_index(n, g.center.x)
		var j = get_index(n, g.center.y)
		matrix[i][j].genes.append(g)
		g.pos = Vector2i(i, j)
	for i in range(1, n+1):
		for j in range(1, n+1):
			matrix[i][j].init(n)

func get_index(n: int, x: float):
	var i = floor((x + 1.0) / 2 * n) + 1
	return clamp(i, 0, n+1)

func get_nbhd(g: Gene):
	var nbhood:= []
	for i in range(
		clampi(g.pos.x - 1, 1, n),
		clampi(g.pos.x + 1, 1, n) + 1
	):
		for j in range(
			clampi(g.pos.y - 1, 1, n),
			clampi(g.pos.y + 1, 1, n) + 1,
		):
			var node = matrix[i][j]
			if true: # TODO intersect(node, gene) != phi:
				nbhood.append(node)
	return nbhood

func dissect(radius: float):
	init_matrix(radius)
	for g in genes:
		var nbhood = get_nbhd(g)
		var needed = false
		for node in nbhood:
			var ret = node.slice(g, radius)
			if ret is String and ret == "error":
				return "error"
			if ret:
				needed = true
		if needed:
			g.active = true
			for node in nbhood:
				node.subsets = node.newsubs
		for node in nbhood:
			node.newsubs = []

