extends RefCounted

class_name Pool

var name:= ""
var radius:= 0.6
var chromosomes:= []
var i:= 1

var rel:= 0.9
var mult_g:= 0.01
var mult_d:= 1.0

func add(ch: Chromosome):
	if ch.calc_score(radius, false, rel, mult_g, mult_d) == "error":
		pass
	else:
		chromosomes.append(ch)

func sort():
	chromosomes.sort_custom(func (a, b): return a.score > b.score)

func to_dict():
	var chs = []
	for ch in chromosomes:
		chs.append(ch.to_dict())
	return {
		"radius": radius,
		"chromosomes": chs
	}

static func from_dict(d):
	var p = Pool.new()
	p.radius = d.radius
	for ch in d.chromosomes:
		p.chromosomes.append(Chromosome.from_dict(ch, p.radius, p.mult_g, p.mult_d))
	return p
