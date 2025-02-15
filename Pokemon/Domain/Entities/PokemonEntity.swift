struct PokemonEntity: Equatable {
    let id: Int
    let name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    var imageUrl: String {
        return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
    }
}
