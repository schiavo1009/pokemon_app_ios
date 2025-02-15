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
            _ = try await datasource.getPokemons();
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
            _ = try await datasource.getPokemons()
        }catch {
            XCTAssertEqual(clientHttp.requestedUrl, "https://pokeapi.co/api/v2/pokemon", "Expected requestedUrl to be https://pokeapi.co/api/v2/pokemon, but was \(clientHttp.requestedUrl ?? "")")
        }
        
    }
    
    func testRequestCalledGetPokemonsErrorClientHttp() async throws {
        let datasource: PokemonDatasource = PokemonDatasourceImpl(clientHttp: clientHttp)
        clientHttp.responseError = ErrorClientHttp(statusCode: 400, message: "Error")
        do {
            _ =  try await datasource.getPokemons();
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
            _ = try await datasource.getPokemons();
            XCTFail("Expected error thrown")
        }catch {
            XCTAssertEqual(error is GenericError,  true)
        }
    }
    
    func testRequestCalledGetPokemonsSuccessResponse() async throws {
        let datasource: PokemonDatasource = PokemonDatasourceImpl(clientHttp: clientHttp)
        clientHttp.responseError = nil
        clientHttp.responseData = responseOnePokemon
        let data = try await datasource.getPokemons();
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
        let data = try await datasource.getPokemons();
        XCTAssertEqual(data, [])
    }
}

class ClientHttpSpy: ClientHttp {
    var getCalledCount = 0
    var responseData: Data?
    var responseError: Error?
    var requestedUrl: String?
    
    func get(url: String) async throws -> Data  {
        requestedUrl = url
        getCalledCount += 1
        if let responseError = responseError {
            throw responseError
        }
        return responseData ?? Data()
    }
}



