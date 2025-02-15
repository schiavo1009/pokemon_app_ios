class FetchPokemonsUsecaseImpl: FetchPokemonsUsecase {
    let repository: PokemonRepository
    
    init(repository: PokemonRepository) {
        self.repository = repository
    }
    
    func getPokemons(offset: Int?, limit: Int?) async -> Result<[PokemonEntity], any Error> {
        let result = await repository.getPokemons(offset: offset ?? 0, limit: limit ?? 20)
        return result
    }
}
