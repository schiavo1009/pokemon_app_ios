import Foundation

class PokemonDatasourceImpl: PokemonDatasource {
    let urlPokemons = "https://pokeapi.co/api/v2/pokemon"
    private let clientHttp: ClientHttp
    init(clientHttp: ClientHttp) {
        self.clientHttp = clientHttp
    }
    
    func getPokemons(offset: Int? = nil, limit: Int? = nil) async throws -> [PokemonModel] {
        do{
            let data =  try await clientHttp.get(url: urlPokemons, queryParams: ["offset": offset ?? 0, "limit": limit ?? 15])
            let decoder = JSONDecoder()
            let response = try decoder.decode(PokemonResponse.self, from: data)
            return response.results
        } catch {
            throw error
        }
    }
}
    

