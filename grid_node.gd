extends RefCounted

class_name GridNode

const TOL = 1e-6

var pos:= Vector2i()
var genes: Array[Gene]= []
var area:= []
var subsets: Array[Subset]= []
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
	var center = g.center
	newsubs = []
	for sset in subsets:
		var int_comps = []
		var ext_comps = []
		for comp in sset.comps:
			var ps: Array[PointData]= []
			for i in len(comp):
				var edge = comp[i]
				if edge is Edge:
					var normal = (edge.v1 - edge.v2).orthogonal().normalized()
					var c_line = edge.v1.dot(normal)
					var c_circ = center.dot(normal)
					var d = abs(c_line-c_circ)
					if c_circ >= c_line + radius - TOL:
						continue # outside
					if c_circ <= c_line - radius - TOL:
						continue # strictly inside
					var th = acos((c_circ - c_line) / radius)
					var u1 = center + radius * (-normal).rotated(+th)
					var u2 = center + radius * (-normal).rotated(-th)
					
					var pds = []
					
					if (u1-u2).length() < TOL:
						var u = center - radius * normal
						pds = [PointData.new(u, i, center, IN_IN)]
					else:
						pds = [
							PointData.new(u1, i, center, IN_OUT),
							PointData.new(u2, i, center, OUT_IN),
						]
					for pd in pds:
						var u = pd.p
						var v = (edge.v2 - edge.v1)
						if (
							v.dot(u-edge.v1) >= 0 and
							(-v).dot(u-edge.v2) >= 0
						):
							ps.append(pd)
			
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
			if k == -1:
				continue # TODO: only IN_IN
			var v1
			var v2
			var u1
			var u2
			var compi = []
			var compes = []
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
			newsubs.append(s)
			
		if len(ext_comps) != 0:
			var s = Subset.new()
			s.comps = ext_comps
			newsubs.append(s)
		

func is_circle_outside(comp, center, radius):
	for edge in comp:
		for v in [edge.v1, edge.v2]:
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
	var u = p1.p
	var edge = comp[i]
	var v = (edge.v2 - edge.v1)
	v.dot(u-edge.v1)
	(-v).dot(u-edge.v2) >= 0
	pass

func merge_points(ps: Array[PointData]):
	var ret = []
	for i in len(ps):
		if (
			(ps[i].p - ps[i-1].p).length() < TOL and 
			ps[i].dir == ps[i-1].dir
		):
			pass
		else:
			ret.append(ps[i])
	return ret


const OUT_IN = -1
const IN_IN = 0
const IN_OUT = +1

class PointData extends RefCounted:
	var p:= Vector2()
	var i:= -1
	var dir:= IN_OUT
	var angle:= 0.0
	
	func _init(p: Vector2, i: int, center: Vector2, dir:=IN_OUT):
		self.p = p
		self.i = i
		self.dir = dir
		self.angle = (p-center).angle()

class Edge extends RefCounted:
	var v1:= Vector2()
	var v2:= Vector2()
	var dir:= 1
	
	func _init(v1: Vector2, v2: Vector2, dir:=1):
		self.v1 = v1
		self.v2 = v2
		self.dir = dir

class Arc extends RefCounted:
	var center:= Vector2()
	var v1:= Vector2()
	var v2:= Vector2()
	var dir:= 1
	
	func _init(center: Vector2, v1: Vector2, v2: Vector2, dir:=1):
		self.center = center
		self.v1 = v1
		self.v2 = v2
		self.dir = dir

class Subset extends RefCounted:
	var comps:= []
	
