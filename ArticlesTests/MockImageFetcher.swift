import UIKit
@testable import Articles

final class MockImageFetcher: ImageFetching {
    var result: Result<UIImage, Error>!
    
    func fetchThumbnailImage(for url: URL, size: CGSize) -> Future<UIImage> {
        return fetchImage(for: url)
    }
    
    func fetchImage(for url: URL) -> Future<UIImage> {
        let promise = Promise<UIImage>()
        
        switch result {
        case .success(let image):
            promise.resolve(with: image)
        case .failure(let error):
            promise.reject(with: error)
        case .none:
            break
        }
        
        return promise
    }
    
    func image(for url: URL) -> UIImage? {
        return nil
    }
}
