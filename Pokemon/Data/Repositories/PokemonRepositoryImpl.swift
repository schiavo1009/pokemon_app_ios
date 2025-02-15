class PokemonRepositoryImpl: PokemonRepository {
    let datasource: PokemonDatasource
    
    init(datasource: PokemonDatasource) {
        self.datasource = datasource
    }
    
    func getPokemons(offset: Int, limit: Int) async -> Result<[PokemonEntity], any Error> {
        do {
            let result = try await datasource.getPokemons(offset: offset, limit: limit)
            let pokemons = result.enumerated().map { (index, pokemon) in
                PokemonModel.toEntity(id: index + 1 + offset, pokemoModel: pokemon)
            }
            return .success(pokemons)
        }catch {
            return .failure(error)
        }
    }
}
