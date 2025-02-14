import Foundation
struct PokemonModel: Codable, Equatable {
    let name: String
}

extension PokemonModel {
    static func decodeList(data: Data) throws -> [PokemonModel] {
        let decoder = JSONDecoder()
        return try decoder.decode([PokemonModel].self, from: data)
    }
}

