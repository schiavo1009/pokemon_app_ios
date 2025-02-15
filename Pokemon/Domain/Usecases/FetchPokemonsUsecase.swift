protocol FetchPokemonsUsecase {
    func getPokemons(offset: Int?, limit: Int?) async -> Result<[PokemonEntity], Error>
}
