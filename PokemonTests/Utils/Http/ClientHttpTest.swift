import Testing
import XCTest
import Foundation
@testable import Pokemon


class ClientHttpTests : XCTestCase {
    var sessionMock: URLSession!
    var config: URLSessionConfiguration!
    var sut: ClientHttpImpl!
    let url = "https://pokeapi.co/api/v2/pokemon"
    
    override func setUp() {
        super.setUp()
        config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        sessionMock = URLSession(configuration: config)
        sut = ClientHttpImpl(session: sessionMock)
    }
    
    
    func testGetRequestInvalidUrl() async throws {
        MockURLProtocol.mockData = Data()
        do {
            _ = try await sut.get(url: "")
            XCTFail("Expected error type")
        }catch{
            XCTAssertEqual(error is ErrorClientHttp, true)
        }
    }
    
    func testGetRequestSuccess200() async throws {
        MockURLProtocol.mockData = Data()
        MockURLProtocol.mockError = nil
        MockURLProtocol.mockResponse = HTTPURLResponse(url: URL(string: url)!, statusCode: 200, httpVersion: nil, headerFields: nil)
        do {
            let result = try await sut.get(url: url)
            XCTAssertEqual(result, Data())
        }catch{
            XCTFail("Unexpected error type")
        }
    }
    
    func testGetRequest200Family() async throws {
        MockURLProtocol.mockData = Data()
        MockURLProtocol.mockResponse = HTTPURLResponse(url: URL(string: url)!, statusCode: 201, httpVersion: nil, headerFields: nil)
        do {
            let result = try await sut.get(url: url)
            XCTAssertEqual(result, Data())
        }catch{
            XCTFail("Unexpected error type")
        }
    }
    
    func testGetRequestError() async throws {
        MockURLProtocol.mockError = NSError(domain: "Error", code: 0, userInfo: nil)
        do {
            _ = try await sut.get(url: url)
            XCTFail("Expected error type")
        }catch{
            XCTAssertEqual((error as NSError).domain, "Error")
        }
    }
    
    func testGetRequestDiferent200FamilyError() async throws {
        MockURLProtocol.mockError = nil
        MockURLProtocol.mockData = Data()
        MockURLProtocol.mockResponse = HTTPURLResponse(url: URL(string: url)!, statusCode: 400, httpVersion: nil, headerFields: nil)
        do {
            _ = try await sut.get(url: url)
            XCTFail("Expected error type")
        }catch{
            XCTAssertEqual(error is ErrorClientHttp, true)
            XCTAssertEqual((error as! ErrorClientHttp).statusCode, 400)
            XCTAssertEqual((error as! ErrorClientHttp).message, "Error")
        }
    }
    
}

class MockURLProtocol: URLProtocol {
    
    static var mockData: Data?
    static var mockResponse: URLResponse?
    static var mockError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
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
