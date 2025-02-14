import Foundation
protocol PokemonDatasource {
    func getPokemons() async throws -> [PokemonModel]
}
    
class PokemonDatasourceImpl: PokemonDatasource {
    let urlPokemons = "https://pokeapi.co/api/v2/pokemon"
    private let clientHttp: ClientHttp
    init(clientHttp: ClientHttp) {
        self.clientHttp = clientHttp
    }
    
    func getPokemons() async throws -> [PokemonModel] {
        do{
            let data =  try await clientHttp.get(url: urlPokemons)
            let decoder = JSONDecoder()
            let response = try decoder.decode(PokemonResponse.self, from: data)
            return response.results
        } catch {
            throw error
        }
    }
}
    

