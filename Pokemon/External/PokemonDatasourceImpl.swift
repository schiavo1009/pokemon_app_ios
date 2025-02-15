import Foundation

class PokemonDatasourceImpl: PokemonDatasource {
    let urlPokemons = "https://pokeapi.co/api/v2/pokemon"
    private let clientHttp: ClientHttp
    init(clientHttp: ClientHttp) {
        self.clientHttp = clientHttp
    }
    
    func getPokemons(offset: Int, limit: Int) async throws -> [PokemonModel] {
        do{
            let data =  try await clientHttp.get(url: urlPokemons, queryParams: ["offset": offset, "limit": limit])
            let decoder = JSONDecoder()
            let response = try decoder.decode(PokemonResponse.self, from: data)
            return response.results
        } catch {
            throw error
        }
    }
}
    

