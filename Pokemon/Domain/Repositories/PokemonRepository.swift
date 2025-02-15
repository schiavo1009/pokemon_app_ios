protocol PokemonRepository {
    func getPokemons(offset: Int, limit: Int) async -> Result<[PokemonEntity], Error>
}
