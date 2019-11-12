import XCTest
@testable import Articles

final class HTTPClientTests: XCTestCase {
    private let mockSession = MockURLSession()
    private lazy var sut = HTTPClient(session: mockSession)
    
    func testErrorEquality() {
        XCTAssertEqual(HTTPClient.Error.HTTPStatus(200, nil), HTTPClient.Error.HTTPStatus(200, nil))
        XCTAssertEqual(HTTPClient.Error.HTTPStatus(200, "a".data(using: .utf8)), HTTPClient.Error.HTTPStatus(200, "a".data(using: .utf8)))
        XCTAssertNotEqual(HTTPClient.Error.HTTPStatus(404, nil), HTTPClient.Error.HTTPStatus(200, nil))
        XCTAssertNotEqual(HTTPClient.Error.HTTPStatus(404, "a".data(using: .utf8)), HTTPClient.Error.HTTPStatus(404, "b".data(using: .utf8)))
    }
    
    func testResponseParsing() {
        let data = "abc".data(using: .utf8)
        let httpResponse200 = HTTPURLResponse(url: URL(string: "http://www.example.com")!, statusCode: 200, httpVersion: "1.1", headerFields: nil)!
        let httpResponse253 = HTTPURLResponse(url: URL(string: "http://www.example.com")!, statusCode: 253, httpVersion: "1.1", headerFields: nil)!
        let httpResponse404 = HTTPURLResponse(url: URL(string: "http://www.example.com")!, statusCode: 404, httpVersion: "1.1", headerFields: nil)!
        
        if case let .success(outData) = HTTPClient.parse(data, httpResponse200, nil) {
            XCTAssertEqual(data, outData)
        } else { XCTFail("Failed to parse success") }
        
        if case let .success(outData) = HTTPClient.parse(data, httpResponse253, nil) {
            XCTAssertEqual(data, outData)
        } else { XCTFail("Failed to parse success") }
        
        if case .failure = HTTPClient.parse(data, httpResponse404, "some error") {
        } else { XCTFail("Failed to parse error") }
        
        if case let .success(data) = HTTPClient.parse(nil, httpResponse200, nil) {
            XCTAssertEqual(data.count, 0)
        } else { XCTFail("Failed to parse error") }
        
        if case .failure = HTTPClient.parse(data, httpResponse200, "some error") {
        } else { XCTFail("Failed to parse error") }
        
        if case let .failure(error) = HTTPClient.parse(data, httpResponse404, nil), let outError = error as? HTTPClient.Error {
            XCTAssertEqual(HTTPClient.Error.HTTPStatus(404, data), outError)
        } else { XCTFail("Failed to parse error") }
        
        if case let .failure(error) = HTTPClient.parse(nil, httpResponse404, nil), let outError = error as? HTTPClient.Error {
            XCTAssertEqual(HTTPClient.Error.HTTPStatus(404, nil), outError)
        } else { XCTFail("Failed to parse error") }
    }
    
    func testSuccessfullLoadingURL() {
        let expectedData = "This is a data".data(using: .utf8)
        mockSession.mockData = expectedData
        
        let successExpectation = XCTestExpectation()
        
        let errorExpectation = XCTestExpectation()
        errorExpectation.isInverted = true
        
        sut.load(url: URL(string: "https://example.com")!).observe { result in
            switch result {
            case .success:
                successExpectation.fulfill()
            case .failure:
                errorExpectation.fulfill()
            }
        }
        
        wait(for: [successExpectation, errorExpectation], timeout: 0.5)
    }
    
    func testFailedLoadingURL() {
        mockSession.mockError = "This is an error"
        
        let successExpectation = XCTestExpectation()
        successExpectation.isInverted = true
        
        let errorExpectation = XCTestExpectation()
        
        sut.load(url: URL(string: "https://example.com")!).observe { result in
            switch result {
            case .success:
                successExpectation.fulfill()
            case .failure:
                errorExpectation.fulfill()
            }
        }
        
        wait(for: [successExpectation, errorExpectation], timeout: 0.5)
    }
}
