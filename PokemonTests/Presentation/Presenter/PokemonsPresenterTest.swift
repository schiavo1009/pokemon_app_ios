@testable import Pokemon
import Testing
import XCTest

class PokemonsPresenterTest: XCTestCase {
    var sut: PokemonsPresenter!
    var fetchPokemonsUsecase: FetchPokemonsUsecaseSpy!
    let pokemon = PokemonEntity(id: 1, name: "Bulbasaur")
    
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
        await sut.fetchPokemons(loadMore: false)
        XCTAssertEqual(sut.pokemons, [])
    }
    
    func testWithOffsetAndLimitParamsInFirstCallFetchPokemon() async throws {
        await sut.fetchPokemons(loadMore: false)
        XCTAssertEqual(fetchPokemonsUsecase.offset, 0)
        XCTAssertEqual(fetchPokemonsUsecase.limit, 20)
    }
    
    func testVariablePokemonsShouldBeFillQithPokemonsWhenFetchUsecaseReturn() async throws {
      let pokemonsList = [pokemon]
        fetchPokemonsUsecase.mockedResponse = pokemonsList
      await sut.fetchPokemons(loadMore: false)
        XCTAssertEqual(sut.pokemons, pokemonsList)
    }
    
    func testLoadingVariableChangeWithCalledUsecase() async throws {
        sut.isLoading = true
        await sut.fetchPokemons(loadMore: false)
        XCTAssertEqual(sut.isLoading, false)
    }
    
    func testErrorFetchPokemonsWhenErrorIsGenericError() async throws {
        XCTAssertEqual(sut.error, nil)
        fetchPokemonsUsecase.mockedError = GenericError()
        await sut.fetchPokemons(loadMore: false)
        XCTAssertEqual(sut.error, "Unexpected error, try again")
    }
    
    func testCalledFetchPokemonOnceAfterErrorAndErrorShouldBeNil() async throws {
        fetchPokemonsUsecase.mockedError = GenericError()
        await sut.fetchPokemons(loadMore: false)
        XCTAssertEqual(sut.error, "Unexpected error, try again")
        fetchPokemonsUsecase.mockedError = nil
        fetchPokemonsUsecase.mockedResponse = []
        await sut.fetchPokemons(loadMore: false)
        XCTAssertEqual(sut.error, nil)
    }
    
    func testShouldCallFetchPokemonForPagination() async throws {
        fetchPokemonsUsecase.mockedResponse = [
            pokemon
        ]
        fetchPokemonsUsecase.mockedError = nil
        await sut.fetchPokemons(loadMore: false)
        XCTAssertEqual(sut.isLoading, false)
        XCTAssertEqual(sut.pokemons, [pokemon])
        await sut.fetchPokemons(loadMore: true)
        XCTAssertEqual(fetchPokemonsUsecase.offset, 1)
        XCTAssertEqual(fetchPokemonsUsecase.limit, 20)
        XCTAssertEqual(sut.pokemons, [pokemon, pokemon])
    }
    
    func testFetchpokemonsShouldNotDoAnyErrorWhenCalledWithLoadMore() async throws {
        fetchPokemonsUsecase.mockedError = GenericError()
        await sut.fetchPokemons(loadMore: true)
        XCTAssertEqual(sut.error, nil)

    }
    
}

class FetchPokemonsUsecaseSpy : FetchPokemonsUsecase {
    var getCalledCount = 0
    var mockedResponse: [PokemonEntity] = []
    var mockedError: Error?
    var offset: Int?
    var limit: Int?
    func getPokemons(offset: Int?, limit: Int?) async -> Result<[PokemonEntity], any Error> {
        self.offset = offset
        self.limit = limit
        getCalledCount += 1
        if let error = mockedError{
            return .failure(error)
        }
        return .success(mockedResponse)
    }
}
