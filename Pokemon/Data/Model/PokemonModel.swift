import Foundation

struct PokemonModel: Codable, Equatable {
    let name: String
    
 }

extension PokemonModel {
    
    static func toEntity(id: Int, pokemoModel: PokemonModel) -> PokemonEntity {
        return PokemonEntity(id: id, name: pokemoModel.name)
    }
}


