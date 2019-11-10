import XCTest
import UIKit
@testable import Articles

final class ImageFetchTests: XCTestCase {
    private let sut = UIImageView()
    private let mockImageFetcher = MockImageFetcher()
    
    func testSuccessfullFetchingThumbnail() {
        let expectedImage = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image {_ in }
        mockImageFetcher.result = .success(expectedImage)
        
        let expectation = XCTKVOExpectation(keyPath: "image", object: sut, expectedValue: expectedImage)
        
        sut.fetchThumbnailImage(for: URL(string: "http://example.com/image.png")!, size: CGSize(width: 10, height: 10), using: mockImageFetcher)
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testSuccessfullFetchingImage() {
        let expectedImage = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image {_ in }
        mockImageFetcher.result = .success(expectedImage)
        
        let expectation = XCTKVOExpectation(keyPath: "image", object: sut, expectedValue: expectedImage)
        
        sut.fetchImage(for: URL(string: "http://example.com/image.png")!, using: mockImageFetcher)
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testFailedFetchingThumbnailWithPlaceholder() {
        sut.image = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image {_ in }
        mockImageFetcher.result = .failure("This is an error")
        
        let expectation = XCTKVOExpectation(keyPath: "image", object: sut, expectedValue: nil)
        
        let placeholderImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image {_ in }
        sut.fetchThumbnailImage(for: URL(string: "http://example.com/image.png")!, size: CGSize(width: 10, height: 10), placeholderImage: placeholderImage, using: mockImageFetcher)
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testFailedFetchingImageWithPlaceholder() {
        sut.image = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image {_ in }
        mockImageFetcher.result = .failure("This is an error")
        
        let expectation = XCTKVOExpectation(keyPath: "image", object: sut, expectedValue: nil)
        
        let placeholderImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image {_ in }
        sut.fetchImage(for: URL(string: "http://example.com/image.png")!, placeholderImage: placeholderImage, using: mockImageFetcher)
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testFailedFetchingThumbnailWithoutPlaceholder() {
        mockImageFetcher.result = .failure("This is an error")
        
        let expectation = XCTKVOExpectation(keyPath: "image", object: sut, expectedValue: nil)
        
        sut.fetchThumbnailImage(for: URL(string: "http://example.com/image.png")!, size: CGSize(width: 10, height: 10), using: mockImageFetcher)
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testFailedFetchingImageWithoutPlaceholder() {
        mockImageFetcher.result = .failure("This is an error")
        
        let expectation = XCTKVOExpectation(keyPath: "image", object: sut, expectedValue: nil)
        
        sut.fetchImage(for: URL(string: "http://example.com/image.png")!, using: mockImageFetcher)
        
        wait(for: [expectation], timeout: 0.5)
    }
}
