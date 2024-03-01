extends RefCounted

class_name Pool

var radius:= 0.6
var chromosomes:= []

func add(ch: Chromosome):
	chromosomes.append(ch)
	ch.calc_score(radius)

func sort():
	chromosomes.sort_custom(func (a, b): return a.score < b.score)
