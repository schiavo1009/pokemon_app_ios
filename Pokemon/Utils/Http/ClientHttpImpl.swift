import Foundation
class ClientHttpImpl: ClientHttp {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(url: String) async throws -> Data {
        
        guard let url = URL(string: url) else {
            throw ErrorClientHttp(statusCode: nil, message: "Invalid URL")
        }
        
        let (data, response) = try await session.data(for: URLRequest(url: url))
        
        guard let httpResponse = response as? HTTPURLResponse  else {
            throw ErrorClientHttp(statusCode: nil, message: "Invalid Response")
        }
        
        if(httpResponse.statusCode == 200){
            return data
        } else {
            throw ErrorClientHttp(statusCode: (response as? HTTPURLResponse)?.statusCode, message: "Error")
        }
 
    }
    
}
