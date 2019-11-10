import XCTest
@testable import Articles

final class ImageFetcherTests: XCTestCase {
    private let mockSession = MockURLSession()
    private lazy var mockHTTPClient = HTTPClient(session: mockSession)
    private let mockCacheFolderURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("Images")
    private lazy var sut = ImageFetcher(httpClient: mockHTTPClient, cacheFolderURL: mockCacheFolderURL)
    
    override func setUp() {
        super.setUp()
        XCTAssertNoThrow(try FileManager.default.createDirectory(at: mockCacheFolderURL, withIntermediateDirectories: true, attributes: nil))
    }
    
    override func tearDown() {
        super.tearDown()
        XCTAssertNoThrow(try FileManager.default.removeItem(at: mockCacheFolderURL))
    }
    
    func testEmptyCacheAndMalformedImageData() {
        let url = URL(string: "http://localhost/123.png")!
        mockSession.mockData = Data()
        
        let result = fetchImage(from: sut, for: url)
        
        if case .failure(ImageFetcher.Error.imageDecoding)? = result {
        } else {
            XCTFail("Success on malformed image data")
        }
        
        XCTAssertNil(sut.image(for: url))
    }
    
    func testDiskCache() {
        let url = URL(string: "http://localhost/234.png")!
        let imageData = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).pngData {_ in }
        
        let imageName = ImageFetcher.fileName(for: url)
        let imageURL = mockCacheFolderURL.appendingPathComponent(imageName)
        XCTAssertNoThrow(try imageData.write(to: imageURL))
        
        let result = fetchImage(from: sut, for: url)
        
        if case .success? = result {
        } else {
            XCTFail("Error on loading image from disk cache")
        }
        
        XCTAssertNotNil(sut.image(for: url))
    }
    
    func testEmptyCacheAndImageData() {
        let url = URL(string: "http://localhost/1233.png")!
        let image = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image {_ in }

        mockSession.mockData = image.pngData()
        
        let result = fetchImage(from: sut, for: url)
        
        if case .success? = result {
        } else {
            XCTFail("Error on loading image from network cache")
        }
        
        XCTAssertNotNil(sut.image(for: url))
    }
    
    // MARK: -
    
    private func fetchImage(from imageFetcher: ImageFetching, for url: URL, cancel: Bool = false) -> Result<UIImage, Error>? {
        let expectation = XCTestExpectation()
        
        var receivedResult: Result<UIImage, Error>?
        imageFetcher.fetchImage(for: url).observe { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
        
        return receivedResult
    }
}
