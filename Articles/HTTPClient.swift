import Foundation

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

final class HTTPClient {
    private let session: URLSessionProtocol
    
    enum Error: Swift.Error, Equatable {
        case HTTPStatus(Int, Data?)
    }
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    static func parse(_ data: Data?, _ response: URLResponse?, _ error: Swift.Error?) -> Result<Data, Swift.Error> {
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        if let statusCode = statusCode, !(200..<400).contains(statusCode) {
            return .failure(Error.HTTPStatus(statusCode, data))
        } else if let error = error {
            return .failure(error)
        } else {
            return .success(data ?? Data())
        }
    }
    
    func load(url: URL) -> Future<Data> {
        return load(request: URLRequest(url: url))
    }
    
    func load(request: URLRequest) -> Future<Data> {
        let promise = Promise<Data>()
            
        let task = session.dataTask(with: request) { data, response, error in
            let result = HTTPClient.parse(data, response, error)
            switch result {
            case let .failure(error):
                if !error.isHTTPCancelError {
                    print("Failed to load \"\(request.url!)\": \(error)")
                }
                promise.reject(with: error)
            case .success(let data):
                promise.resolve(with: data)
            }
        }
        
        task.resume()
        
        return promise
    }
}

private extension Error {
    var isHTTPCancelError: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled
    }
}

extension URLSession: URLSessionProtocol {
}
