module geneticalg

import rand

pub struct Genotype {
pub mut:
	genes []int
	fitness int
}

pub fn (gt Genotype) clone() Genotype {
	mut gt2 := Genotype{}
	gt2.genes = gt.genes.clone()
	gt2.fitness = gt.fitness
	return gt2
}

pub struct GA {
pub mut:
	num_generations int
	population_sz int
	population []Genotype
	mutation_probability f32
	mutation_variability int
	num_of_genes int
	min_gene_value int
	max_gene_value int
	top int
	random_elements int
	num_diversity int
	max_fitness int
	evaluation_callback fn (mut gt Genotype)
	show_top10 bool
}

pub fn new() &GA {
	mut ga := &GA{}
	ga.num_generations = 10000
	ga.population_sz = 100
	ga.mutation_probability = 0.5
	ga.mutation_variability = 1
	ga.num_of_genes = 5
	ga.top = 10
	ga.min_gene_value = 0
	ga.max_gene_value = 100
	ga.num_diversity = 5
	ga.random_elements = 3
	ga.max_fitness = 99
	ga.show_top10 = false
	ga.on_evaluation(dummy_evaluation)
	return ga
}

pub fn (ga GA) get_random_genotype() Genotype {	
	mut g := Genotype{}
	for _ in 0..ga.num_of_genes {
		g.genes << (rand.intn(ga.max_gene_value)+ga.min_gene_value)
	}
	g.fitness = 0
	return g
}

pub fn (mut ga GA) randomize_population() {
	ga.population = []Genotype{}
	
	for _ in 0..ga.population_sz {
		ga.population << ga.get_random_genotype()
	}
}

pub fn dummy_evaluation(mut gt Genotype) {
	gt.fitness = 0
}

pub fn (mut ga GA) on_evaluation(cb fn (mut gt Genotype)) {
	ga.evaluation_callback = cb
}

pub fn (mut ga GA) evaluation() {
	for i in 0..ga.population.len {
		ga.evaluation_callback(mut ga.population[i])
	}
}


pub fn (mut ga GA) sort() {
	for i:=ga.population.len-1; i>0; i-- {
		for j in 0..i {
			if ga.population[j+1].fitness > ga.population[j].fitness {
				tmp := ga.population[j].clone()
				ga.population[j] = ga.population[j+1].clone()
				ga.population[j+1] = tmp
			}
		}
	}
}

pub fn (mut ga GA) selection() []Genotype {
	mut top10 := []Genotype{}
	ga.sort()

	for i in 0..ga.top {
		top10 << ga.population[i].clone()
	}

	return top10
}

pub fn (mut ga GA) mutate(mut gt Genotype) {
	for i in 0..gt.genes.len {
		if rand.f32() <= ga.mutation_probability {
			if rand.intn(2) == 0 {
				gt.genes[i] += ga.mutation_variability
			} else {
				gt.genes[i] -= ga.mutation_variability
			}
		}
	}
}  

pub fn (mut ga GA) crossover(mut top10 []Genotype, mut ng []Genotype) {
	m := int(ga.num_of_genes/2)

	for ng.len < ga.population_sz {
		a := rand.intn(ga.top/2)
		b := rand.intn(ga.top/2)+(ga.top/2)

		mut c1 := top10[a].clone()
		for i in m..ga.num_of_genes {
			c1.genes[i] = top10[b].genes[i]
		}
		ga.mutate(mut c1)
		ng << c1

		mut c2 := top10[b].clone()
		for i in m..ga.num_of_genes {
			c1.genes[i] = top10[a].genes[i]
		}
		ga.mutate(mut c2)
		ng << c2

		mut c3 := top10[a].clone()
		for i in 0..ga.num_of_genes {
			if i % 2 == 0 {
				c3.genes[i] == top10[b].genes[i]
			}
		}
		ga.mutate(mut c3)
		ng << c3

		mut c4 := top10[b].clone()
		for i in 0..ga.num_of_genes {
			if i % 2 == 0 {
				c4.genes[i] == top10[a].genes[i]
			}
		}
		ga.mutate(mut c4)
		ng << c4
	}
}

pub fn (mut ga GA) start() {
	for g in 1..ga.num_generations {

		fitness := ga.population[0].fitness
		print('generation $g fitness: $fitness genes: ')
		println(ga.population[0].genes)

		if ga.show_top10 {
			for i in 0..ga.top {
				println(ga.population[i])
			}
		}

		if fitness >= ga.max_fitness {
			break
		}
		
		ga.evaluation()
		mut top10 := ga.selection()

		mut ng := []Genotype{}
	
		// preserve the top 4
		
		for i in 0..4 {
			ng << ga.population[i]
		}

		// keep diversity
		for _ in 0..ga.num_diversity {
			idx := rand.intn(ga.population.len - ga.top) + ga.top
			ng << ga.population[idx]
		}

		// random elements
		for _ in 0..ga.random_elements {
			ng << ga.get_random_genotype()
		}
		

		ga.crossover(mut top10, mut ng)

		ga.population = ng
	}
}

