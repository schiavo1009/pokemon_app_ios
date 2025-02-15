import Foundation
import Testing
import XCTest
@testable import Pokemon

class FetchPokemonsUsecaseTests: XCTestCase {
    var sut: FetchPokemonsUsecase!
    var repositorySpy: PokemonRepositorySpy!
    let pokemonOne = PokemonEntity(id: 1, name: "Bulbasaur")
    let pokemonTwo = PokemonEntity(id: 2, name: "Ivysaur")
    
    override func setUp() {
        repositorySpy = PokemonRepositorySpy()
        sut = FetchPokemonsUsecaseImpl(repository: repositorySpy)
    }
    
    func testFetchPokemonsAndCalledRepositoryOnce() async throws {
        _ = await sut.getPokemons(offset: nil, limit:  nil)
        XCTAssertEqual(repositorySpy.getCalledCount, 1, "Expected getCalledCount to be 1, but was \(repositorySpy.getCalledCount)")
    }
    
    func testFetchPokemonsAndReturnEmptyArray() async throws {
        let result = await sut.getPokemons(offset: nil, limit: nil)
        switch result {
        case .success(let pokemons):
            XCTAssertEqual(pokemons, [])
        case .failure:
            XCTFail("Expected success")
        }
    }
    
    func testFetchPokemonRetrieveOnePokemoninArray() async throws {
        repositorySpy.mockedResponse = [pokemonOne]
        let result = await sut.getPokemons(offset: nil, limit: nil)
        switch result {
        case .success(let pokemons):
            XCTAssertEqual(pokemons.count, 1)
            XCTAssertEqual(pokemons.first, pokemonOne)
        case .failure:
            XCTFail("Expected success")
        }
    }
    
    func testFetchPokemonRetrieveTwoPokemoninArray() async throws {
        repositorySpy.mockedResponse = [pokemonOne, pokemonTwo]
        let result = await sut.getPokemons(offset: nil, limit: nil)
        switch result {
        case .success(let pokemons):
            XCTAssertEqual(pokemons.count, 2)
            XCTAssertEqual(pokemons.first, pokemonOne)
            XCTAssertEqual(pokemons.last, pokemonTwo)
        case .failure:
            XCTFail("Expected success")
        }
    }
    
    func testFetchPokemonVerifyParamsMethod() async throws {
        repositorySpy.mockedResponse = [pokemonOne]
        _ = await sut.getPokemons(offset: 0, limit: 10)
        XCTAssertEqual(repositorySpy.offset, 0, "Expected offset to be 1, but was \(repositorySpy.getCalledCount)")
        XCTAssertEqual(repositorySpy.limit, 10, "Expected offset to be 10, but was \(repositorySpy.getCalledCount)")
    }
    
    func testFetchPokemonVerifyParamsMethodWithDefaultValues() async throws {
     _ = await sut.getPokemons(offset: nil, limit: nil)
        XCTAssertEqual(repositorySpy.offset, 0, "Expected offset to be 1, but was \(repositorySpy.getCalledCount)")
        XCTAssertEqual(repositorySpy.limit, 20, "Expected offset to be 10, but was \(repositorySpy.getCalledCount)")
    }
    
    func testFetchPokemonReturnError() async throws {
        repositorySpy.mockedResponse = []
        repositorySpy.mockError = GenericError()
        let result = await sut.getPokemons(offset: nil, limit: nil)
        switch result {
        case  .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertTrue(error is GenericError)
        }
    }
}


class PokemonRepositorySpy: PokemonRepository {
    var mockedResponse: [PokemonEntity] = []
    var mockError: Error?
    var getCalledCount = 0
    var offset = 0
    var limit = 0
    
    func getPokemons(offset: Int, limit: Int) async -> Result<[PokemonEntity], any Error> {
        self.offset = offset
        self.limit = limit
        getCalledCount += 1
        if let mockError = mockError {
            return .failure(mockError)
            
        }
        return .success(mockedResponse)
    }
    
}
