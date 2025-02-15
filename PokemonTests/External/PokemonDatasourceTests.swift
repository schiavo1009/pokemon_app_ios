import Foundation
import Testing
import XCTest
@testable import Pokemon

class PokemonDatasourceTests: XCTestCase {
    
    let clientHttp = ClientHttpSpy()
    let responseOnePokemon = """
        {
            "results": [
                { "name": "Bulbasaur" }
            ]
        }
        """.data(using: .utf8)
    
    func testRequestCalledGetPokemons() async throws {
        let datasource: PokemonDatasource = PokemonDatasourceImpl(clientHttp: clientHttp)
        clientHttp.responseError = nil
        clientHttp.responseData = responseOnePokemon
        do {
            _ = try await datasource.getPokemons(offset: 0, limit: 15);
        }catch {
            XCTFail("Unexpected error type")
        }
        XCTAssertEqual(clientHttp.getCalledCount, 1, "Expected getCalledCount to be 1, but was \(clientHttp.getCalledCount)")
    }
    
    func testRequestCalledWithWrongUrl() async throws {
        let datasource: PokemonDatasource = PokemonDatasourceImpl(clientHttp: clientHttp)
        clientHttp.responseError = nil
        clientHttp.responseData = Data()
        do{
            _ = try await datasource.getPokemons(offset: 0, limit: 15)
        }catch {
            XCTAssertEqual(clientHttp.requestedUrl, "https://pokeapi.co/api/v2/pokemon", "Expected requestedUrl to be https://pokeapi.co/api/v2/pokemon, but was \(clientHttp.requestedUrl ?? "")")
        }
        
    }
    
    func testRequestCalledGetPokemonsErrorClientHttp() async throws {
        let datasource: PokemonDatasource = PokemonDatasourceImpl(clientHttp: clientHttp)
        clientHttp.responseError = ErrorClientHttp(statusCode: 400, message: "Error")
        do {
            _ =  try await datasource.getPokemons(offset: 0, limit: 15);
            XCTFail("Expected error thrown")
        }catch let error as ErrorClientHttp {
            XCTAssertEqual(error.message,  "Error")
            XCTAssertEqual(error.statusCode,  400)
        }catch {
            XCTFail("Unexpected error type")
            
        }
    }
    
    func testRequestCalledGetPokemonsGenericError() async throws {
        let datasource: PokemonDatasource = PokemonDatasourceImpl(clientHttp: clientHttp)
        clientHttp.responseError = GenericError()
        do {
            _ = try await datasource.getPokemons(offset: 0, limit: 15);
            XCTFail("Expected error thrown")
        }catch {
            XCTAssertEqual(error is GenericError,  true)
        }
    }
    
    func testRequestCalledGetPokemonsSuccessResponse() async throws {
        let datasource: PokemonDatasource = PokemonDatasourceImpl(clientHttp: clientHttp)
        clientHttp.responseError = nil
        clientHttp.responseData = responseOnePokemon
        let data = try await datasource.getPokemons(offset: 0, limit: 15);
        XCTAssertEqual(data, [PokemonModel(name: "Bulbasaur")])
    }
    
    func testRequestCalledGetPokemonsSuccessResponseWithEmptyData() async throws {
        let datasource: PokemonDatasource = PokemonDatasourceImpl(clientHttp: clientHttp)
        clientHttp.responseError = nil
        clientHttp.responseData = """
        {
            "results": [
               
            ]
        }
        """.data(using: .utf8)
        let data = try await datasource.getPokemons(offset: 0, limit: 15);
        XCTAssertEqual(data, [])
    }
    
    func testRequestCalledGetPokemonsWithDefaultQueryParams() async throws {
        let datasource: PokemonDatasource = PokemonDatasourceImpl(clientHttp: clientHttp)
        clientHttp.responseError = nil
        clientHttp.responseData = responseOnePokemon
        _ = try await datasource.getPokemons(offset: 0, limit: 15)
        XCTAssertEqual(clientHttp.queryParams?["offset"] as? Int, 0)
        XCTAssertEqual(clientHttp.queryParams?["limit"] as? Int, 15)
        
    }
    
    func testRequestCalledGetPokemonsWithQueryParams() async throws {
        let datasource: PokemonDatasource = PokemonDatasourceImpl(clientHttp: clientHttp)
        clientHttp.responseError = nil
        clientHttp.responseData = responseOnePokemon
        _ = try await datasource.getPokemons(offset: 15, limit: 10)
        XCTAssertEqual(clientHttp.queryParams?["offset"] as? Int, 15)
        XCTAssertEqual(clientHttp.queryParams?["limit"] as? Int, 10)
        
    }
        
}

class ClientHttpSpy: ClientHttp {
    var getCalledCount = 0
    var responseData: Data?
    var responseError: Error?
    var requestedUrl: String?
    var queryParams: [String: Any]?
    
    func get(url: String, queryParams: [String: Any]?) async throws -> Data  {
        self.queryParams = queryParams
        requestedUrl = url
        getCalledCount += 1
        if let responseError = responseError {
            throw responseError
        }
        return responseData ?? Data()
    }
}



