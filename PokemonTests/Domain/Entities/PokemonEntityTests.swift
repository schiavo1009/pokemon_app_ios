import XCTest
import Testing
@testable import Pokemon

class PokemonEntityTests: XCTestCase {
    
    func testInitMethod() async throws {
        let pokemon = PokemonEntity(id: 1,  name: "Bulbasaur")
        XCTAssertEqual(pokemon.id, 1)
        XCTAssertEqual(pokemon.name, "Bulbasaur")
    }
    
    func testGetImageUrl() async throws {
        let pokemon = PokemonEntity(id: 1,  name: "Bulbasaur")
        XCTAssertEqual(pokemon.imageUrl, "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png")
    }
}
