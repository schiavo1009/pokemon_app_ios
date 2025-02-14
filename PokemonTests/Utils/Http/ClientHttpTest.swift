import Testing
import XCTest
import Foundation
@testable import Pokemon


class ClientHttpTests : XCTestCase {
    var sessionMock: URLSession!
    var config: URLSessionConfiguration!

    override func setUp() {
        super.setUp()
        config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        sessionMock = URLSession(configuration: config)
    }


    func testGetRequestInvalidUrl() async throws {
        MockURLProtocol.mockData = Data()
        let sut = ClientHttpImpl(session: sessionMock)
        do {
            _ = try await sut.get(url: "")
            XCTFail("Expected error type")
        }catch{
            XCTAssertEqual(error is ErrorClientHttp, true)
        }
    }

    func testGetRequestSuccess200() async throws {
        MockURLProtocol.mockData = Data()
        MockURLProtocol.mockResponse = HTTPURLResponse(url: URL(string: "https://pokeapi.co/api/v2/pokemon")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let sut = ClientHttpImpl(session: sessionMock)
        do {
            let result = try await sut.get(url: "https://pokeapi.co/api/v2/pokemon")
            XCTAssertEqual(result, Data())
        }catch{
            XCTFail("Unexpected error type")
        }
    }
    
    func testGetRequestErrorDiferent200Family() async throws {
        
        
    }
}

class MockURLProtocol: URLProtocol {
    
    static var mockData: Data?
    static var mockResponse: URLResponse?
    static var mockError: Error?
    
    // Método para interceptar a requisição
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request // Retorna a requisição original
    }
    
    override func startLoading() {
        if let error = MockURLProtocol.mockError {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = MockURLProtocol.mockResponse,
               let data = MockURLProtocol.mockData {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                self.client?.urlProtocol(self, didLoad: data)
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }
    }
    
    override func stopLoading() {
    }
}
