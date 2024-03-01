extends RefCounted

class_name GridNode

const TOL = Global.TOL

const OUT_IN = Global.OUT_IN
const IN_IN = Global.IN_IN
const IN_OUT = Global.IN_OUT

var pos:= Vector2i()
var genes:= []
var area:= []
var subsets:= []
var newsubs:= []
var covered:= false

func init(n):
	var i = pos.x
	var j = pos.y
	
	var a00 = Vector2(i-1, j-1)*2/n + Vector2(-1, -1)
	var a10 = Vector2(i, j-1)*2/n + Vector2(-1, -1)
	var a11 = Vector2(i, j)*2/n + Vector2(-1, -1)
	var a01 = Vector2(i-1, j)*2/n + Vector2(-1, -1)
	area = [
		Edge.new(a00, a10),
		Edge.new(a10, a11),
		Edge.new(a11, a01),
		Edge.new(a01, a00),
	]
	var s = Subset.new()
	s.comps.append(area)
	subsets.append(s)

func intersect(g: Gene, radius: float):
	print(pos)
	var center = g.center
	newsubs = []
	var needed = false
	for sset in subsets:
		var int_comps = []
		var ext_comps = []
		for comp in sset.comps:
			var ps:= []
			for i in len(comp):
				var edge = comp[i]
				var arr = edge.split(center, radius, i)
				ps.append_array(arr)
				
			ps.sort_custom(func (a, b): return a.angle < b.angle)
			ps = merge_points(ps)
			if len(ps) == 0:
				if is_circle_outside(comp, center, radius):
					ext_comps.append(comp)
				else:
					int_comps.append(comp)
				continue
			var k:= -1
			for i in len(ps):
				var p = ps[i]
				if p.dir == OUT_IN:
					k = i
					break
			var compi = []
			var compes = []
			if k == -1: # only IN_IN, only when radius = 1
				for i in len(ps):
					var u1 = ps[i-1]
					var u2 = ps[i]
					var dir = u2.dir
					if dir != IN_IN:
						print("Error")
						continue
					var compe = [Arc.new(center, u2.p, u1.p, -1)]
					compe.append_array(get_b(comp, u1, u2))
					compes.append(compe)
						
				compi.append(Circle.new(center))
				int_comps.append(compi)
				ext_comps.append_array(compes)
				continue
			var v1
			var v2
			var u1
			var u2
			for i in range(k - len(ps), k):
				var dir = ps[i].dir
				if dir == OUT_IN:
					v1 = ps[i]
					u1 = ps[i]
					if v2 != null:
						compi.append_array(get_b(comp, v2, v1))
				else:
					u2 = ps[i]
					var compe = [Arc.new(center, u2.p, u1.p, -1)]
					compe.append_array(get_b(comp, u1, u2))
					compes.append(compe)
					if dir == IN_IN:
						u1 = u2
				if dir == IN_OUT:
					v2 = ps[i]
					compi.append(Arc.new(center, v1.p, v2.p, 1))
			compi.append_array(get_b(comp, v2, ps[k]))
			int_comps.append(compi)
			ext_comps.append_array(compes)
		
		if len(int_comps) != 0:
			var s = Subset.new()
			s.comps = int_comps
			if len(sset.genes) < 2:
				needed = true
			s.genes.append(g)
			newsubs.append(s)
			
		if len(ext_comps) != 0:
			var s = Subset.new()
			s.comps = ext_comps
			s.out_genes.append(g)
			newsubs.append(s)
	
	return needed

func is_circle_outside(comp, center, radius):
	for edge in comp:
		var vs
		if edge is Circle:
			vs = [edge.center]
		else:
			vs = [edge.v1, edge.v2]
		for v in vs:
			var d = (v - center).length()
			if d <= radius - TOL:
				return false
			if d >= radius + TOL:
				return true
	return false

func get_b(comp: Array, p1: PointData, p2: PointData):
	var i = p1.i
	var j = p2.i
	var ret = []
	
	if i == j:
		var edge = comp[i]
		if edge is Edge:
			return [Edge.new(p1.p, p2.p)]
		else: # if edge is Arc or edge is Circle:
			return [Arc.new(comp[i].center, p1.p, p2.p)]
	
	var u1 = p1.p
	var edge = comp[i]
	
	if (u1-edge.v1).length() <= TOL:
		ret.append(edge)
	elif (u1-edge.v2).length() < TOL:
		pass
	else:
		if edge is Edge:
			ret.append(Edge.new(u1, edge.v2))
		if edge is Arc:
			ret.append(Arc.new(edge.center, u1, edge.v2, edge.dir))
	
	var n = len(comp) if i>j  else 0
	for k in range(i+1 - n, j):
		ret.append(comp[k])
	
	var u2 = p2.p
	edge = comp[j]
	
	if (u1-edge.v1).length() <= TOL:
		pass
	elif (u1-edge.v2).length() < TOL:
		ret.append(edge)
	else:
		if edge is Edge:
			ret.append(Edge.new(edge.v1, u2))
		if edge is Arc:
			ret.append(Arc.new(edge.center, edge.v1, u2, edge.dir))
	
	return ret

func merge_points(ps: Array):
	var ret = []
	for i in len(ps):
		if (
			(ps[i].p - ps[i-1].p).length() < 2*TOL and 
			ps[i].dir == ps[i-1].dir
		):
			pass
		else:
			ret.append(ps[i])
	return ret
