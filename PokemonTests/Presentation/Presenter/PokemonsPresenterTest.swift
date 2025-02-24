@testable import Pokemon
import Testing
import XCTest

class PokemonsPresenterTest: XCTestCase {
    var sut: PokemonsPresenterImpl!
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
                fetchPokemonsUsecase.mockedResponse = [
                    pokemon
                ]
                fetchPokemonsUsecase.mockedError = nil
        await sut.fetchPokemons(loadMore: false)
        XCTAssertEqual(sut.pokemons, [pokemon])
    }
    
    func testWithOffsetAndLimitParamsInFirstCallFetchPokemon() async throws {
        await sut.fetchPokemons(loadMore: false)
        XCTAssertEqual(fetchPokemonsUsecase.offset, 0)
        XCTAssertEqual(fetchPokemonsUsecase.limit, 20)
    }
    
    func testLoadingVariableChangeWithCalledUsecase() async throws {
        var verifyLoadingCount = 0
        let cancellable = sut.$isLoading.sink { newValue in
            if(newValue){
                verifyLoadingCount += 1
            }
        }
        
        await sut.fetchPokemons(loadMore: false)
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        cancellable.cancel()
      
        XCTAssertEqual(verifyLoadingCount, 2)

      
    }
    
    func testErrorFetchPokemonsWhenErrorIsGenericError() async throws {
        fetchPokemonsUsecase.mockedError = GenericError()
        await sut.fetchPokemons(loadMore: false)
        XCTAssertTrue(sut.error == "Unexpected error, try again")
    }
    
    func testCalledFetchPokemonOnceAfterErrorAndErrorShouldBeNil() async throws {
        fetchPokemonsUsecase.mockedError = GenericError()
        await sut.fetchPokemons(loadMore: false)
        XCTAssertTrue(sut.error == "Unexpected error, try again")
        fetchPokemonsUsecase.mockedError = nil
        fetchPokemonsUsecase.mockedResponse = []
        await sut.fetchPokemons(loadMore: false)
        XCTAssertTrue(sut.pokemons == [])
    }
    
    func testShouldCallFetchPokemonForPagination() async throws {
        fetchPokemonsUsecase.mockedResponse = [
            pokemon
        ]
        fetchPokemonsUsecase.mockedError = nil
        var verifyLoadingCount = 0
        var verifyLoadingBottomCount = 0
        let cancellable = sut.$isLoading.sink { newValue in
            if(newValue){
                verifyLoadingCount += 1
            }
        }
        
        let cancellableBottom = sut.$isLoadingBottom.sink { newValue in
            if(newValue){
                verifyLoadingBottomCount += 1
            }
        }
        await sut.fetchPokemons(loadMore: false)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        XCTAssertEqual(verifyLoadingCount, 2)
        XCTAssertEqual(sut.pokemons, [pokemon])
        await sut.fetchPokemons(loadMore: true)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        XCTAssertEqual(verifyLoadingBottomCount, 1)
        cancellable.cancel()
        cancellableBottom.cancel()
        XCTAssertEqual(fetchPokemonsUsecase.offset, 1)
        XCTAssertEqual(fetchPokemonsUsecase.limit, 20)
        XCTAssertEqual(sut.pokemons, [pokemon, pokemon])
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
