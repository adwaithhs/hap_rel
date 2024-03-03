extends RefCounted

class_name Pool

var radius:= 0.6
var chromosomes:= []
var i:= 1

func add(ch: Chromosome):
	chromosomes.append(ch)
	ch.calc_score(radius)

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
