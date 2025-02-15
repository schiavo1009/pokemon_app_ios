import XCTest
import Testing
@testable import Pokemon

class PokemonRepositoryTests: XCTestCase {
    var sut: PokemonRepository!
    var datasourceSpy = PokemonDatasourceSpy()
    
    override func setUp() {
        super.setUp()
        sut = PokemonRepositoryImpl(datasource: datasourceSpy)
        datasourceSpy.mockResponse = []
    }
    
    func testShouldCallDatasourceWhenGetPokemons() async throws {
        _ = await sut.getPokemons(offset: 0, limit: 10)
        XCTAssertEqual(datasourceSpy.getCalledCount, 1, "Expected getCalledCount to be 1, but was \(datasourceSpy.getCalledCount)")
    }
    
    func testShouldCallDatasourceAndReturnEmptyListPokemon() async throws {
        let result = await sut.getPokemons(offset: 0, limit: 10)
        
        switch result {
        case .success(let pokemons):
            XCTAssertEqual(pokemons.count, 0)
        case .failure:
            XCTFail("Expected success")
            
        }
    }
    
    func testShouldReturnErrorWhenDatasourceThrows() async throws {
        datasourceSpy.mockError = GenericError()
    
        let result = await sut.getPokemons(offset: 0, limit: 10)
        
        switch result {
        case .success:
            XCTFail("Expected error")
        case .failure(let error):
            XCTAssertEqual(error is GenericError, true)
        }
    }
    
    func testShouldRetrieverOnePokemonSuccessCase() async throws {
        datasourceSpy.mockResponse = [PokemonModel(name: "Bulbasaur")]
        let result = await sut.getPokemons(offset: 0, limit: 10)

        switch result {
        case .success(let pokemons):
            XCTAssertEqual(pokemons.count, 1)
            XCTAssertEqual(pokemons.first, PokemonEntity(id: 1, name: "Bulbasaur"))
        case .failure:
            XCTFail("Expected success")
        }
    }
    
    func testShouldVerifyPokemonIdWhenOffsetDiferrentThanZero() async throws {
        datasourceSpy.mockResponse = [PokemonModel(name: "Bulbasaur")]

        let result = await sut.getPokemons(offset: 10, limit: 10)
        
        switch result {
        case .success(let pokemons):
            XCTAssertEqual(pokemons.first?.id, 11)
        case .failure:
            XCTFail("Expected success")
        }
    }
    
    func testShouldVerifyWithDatasourceRecieveOffsetAndLimit() async throws {
        _ = await sut.getPokemons(offset: 0, limit: 15)
        XCTAssertEqual(datasourceSpy.offset, 0)
        XCTAssertEqual(datasourceSpy.limit, 15)
    }
    
    func testShouldRetrieverTwoPokemonSuccessCase() async throws {
        datasourceSpy.mockResponse = [PokemonModel(name: "Bulbasaur"), PokemonModel(name: "Ivysaur")]
        let result = await sut.getPokemons(offset: 0, limit: 10)
        switch result {
        case .success(let pokemons):
            XCTAssertEqual(pokemons.count, 2)
            XCTAssertEqual(pokemons, [PokemonEntity(id: 1, name: "Bulbasaur"), PokemonEntity(id: 2, name: "Ivysaur")])
        case .failure:
            XCTFail("Expected success")
        }
    }

}

class PokemonDatasourceSpy: PokemonDatasource {
    var mockError: Error?
    var mockResponse: [PokemonModel]!
    var getCalledCount = 0
    var offset: Int?
    var limit: Int?
    
    func getPokemons(offset: Int, limit: Int) async throws -> [PokemonModel] {
        getCalledCount += 1
        self.offset = offset
        self.limit = limit
        if let error = mockError {
            throw error
        }
        return mockResponse
    }
    
}
