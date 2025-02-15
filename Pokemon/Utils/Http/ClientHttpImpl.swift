import Foundation
class ClientHttpImpl: ClientHttp {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(url: String, queryParams: [String: Any]? = nil) async throws -> Data {
        
        guard let url = createURLWithQueryParameters(url: url, queryParams: queryParams) else {
            throw ErrorClientHttp(statusCode: nil, message: "Invalid URL")
        }
        
        let (data, response) = try await session.data(for: URLRequest(url: url))
        
        guard let httpResponse = response as? HTTPURLResponse  else {
            throw ErrorClientHttp(statusCode: nil, message: "Invalid Response")
        }
        
        if(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
            return data
        } else {
            throw ErrorClientHttp(statusCode: (response as? HTTPURLResponse)?.statusCode, message: "Error")
        }
        
    }
    
    func createURLWithQueryParameters(url: String, queryParams: [String: Any]?) -> URL? {
        if(url.isEmpty) {
            return nil
        }
        guard var urlComponents = URLComponents(string: url) else {
            return nil
        }
        if let queryParams = queryParams {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        return urlComponents.url
    }
    
}
