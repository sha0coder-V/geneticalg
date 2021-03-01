import geneticalg 


fn test_geneticalg() {

	mut ga := geneticalg.new()
	ga.population_sz = 50
	ga.top = 10

	ga.randomize_population()

	assert ga.population.len == ga.population_sz

	ga.on_evaluation(fn (mut gt geneticalg.Genotype) {
		// simple evaluation for testing
		gt.fitness = gt.genes[1]
	})

	ga.num_generations = 10
	ga.start()
	
}

