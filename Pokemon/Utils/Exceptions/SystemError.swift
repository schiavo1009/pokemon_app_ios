class GenericError: Error {}
    
class ErrorClientHttp: Error {
    var statusCode: Int?
    var message: String?
    init(statusCode: Int?, message: String?) {
        self.statusCode = statusCode
        self.message = message
    }
}
