@testable import Pokemon
import Testing
import XCTest

class PokemonsPresenterTest: XCTestCase {
    var sut: PokemonsPresenter!
    var fetchPokemonsUsecase: FetchPokemonsUsecaseSpy!
    
    override func setUp() {
        super.setUp()
        fetchPokemonsUsecase = FetchPokemonsUsecaseSpy()
        sut = PokemonsPresenterImpl(fetchPokemonsUsecase: fetchPokemonsUsecase)
    }
    
    func testShouldVerifyWithViewDidLoadCallFetchUsecase() async throws {
        sut.viewDidLoad()
        try await Task.sleep(nanoseconds: 2_000_000_000) 
        XCTAssertEqual(fetchPokemonsUsecase.getCalledCount, 1, "Expected getCalledCount to be 1, but was \(fetchPokemonsUsecase.getCalledCount)")
    }
    
    func testVariablePokemonsShouldBeFillWhenFetchUsecaseReturnSuccess() async throws {
        XCTAssertEqual(sut.pokemons, nil)
        await sut.fetchPokemons()
        XCTAssertEqual(sut.pokemons, [])
    }
    
    func testVariablePokemonsShouldBeFillQithPokemonsWhenFetchUsecaseReturn() async throws {
      let pokemonsList = [PokemonEntity(id: 1, name: "Bulbasaur")]
        fetchPokemonsUsecase.mockedResponse = pokemonsList
      await sut.fetchPokemons()
        XCTAssertEqual(sut.pokemons, pokemonsList)
    }
    
    func testLoadingVariableChangeWithCalledUsecase() async throws {
        sut.isLoading = true
        await sut.fetchPokemons()
        XCTAssertEqual(sut.isLoading, false)
    }
    
    func testErrorFetchPokemonsWhenErrorIsGenericError() async throws {

    }
    
}

class FetchPokemonsUsecaseSpy : FetchPokemonsUsecase {
    var getCalledCount = 0
    var mockedResponse: [PokemonEntity] = []
    
    func getPokemons(offset: Int?, limit: Int?) async -> Result<[PokemonEntity], any Error> {
        getCalledCount += 1
        return .success(mockedResponse)
    }
    
    
}
