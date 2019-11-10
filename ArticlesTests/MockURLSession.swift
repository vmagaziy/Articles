import Foundation
@testable import Articles

final class MockURLSession: URLSessionDataTask, URLSessionProtocol {
    var request: URLRequest?
    
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    private var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.request = request
        self.completionHandler = completionHandler
        return self
    }
    
    override func resume() {
        completionHandler?(mockData, mockResponse, mockError)
    }
    
    override func cancel() {
    }
}
