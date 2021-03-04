import sha0coder_v.geneticalg 


fn main() {

	mut ga := geneticalg.new()
	ga.population_sz = 50
	ga.top = 10

	ga.randomize_population()


	ga.on_evaluation(fn (mut gt geneticalg.Genotype) {
		// simple evaluation for testing
		gt.fitness = gt.genes[0] + gt.genes[1] - gt.genes[3]
	})

	ga.max_fitness = 200
	ga.num_generations = 10000
	ga.start()
}
