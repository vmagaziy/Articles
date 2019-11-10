import UIKit

protocol ImageFetching {
    func fetchThumbnailImage(for url: URL, size: CGSize) -> Future<UIImage>
    func fetchImage(for url: URL) -> Future<UIImage>
    
    func image(for url: URL) -> UIImage?
}

final class ImageFetcher: ImageFetching {
    static let shared = ImageFetcher()
    static let defaultCacheFolderURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    
    private let httpClient: HTTPClient
    private let cacheFolderURL: URL?
    
    private let cachedImages = NSCache<NSString, UIImage>()
    
    enum Error: Swift.Error, Equatable {
        case imageDecoding
    }
    
    init(httpClient: HTTPClient = HTTPClient(), cacheFolderURL: URL? = ImageFetcher.defaultCacheFolderURL) {
        self.httpClient = httpClient
        self.cacheFolderURL = cacheFolderURL
    }
    
    static func fileName(for url: URL) -> String {
        return url.path.replacingOccurrences(of: "/", with: "_", options: [], range: nil).replacingOccurrences(of: ":", with: "--", options: [], range: nil)
    }
    
    /// Gets thumbnail from in-memory cache, if found it's returned;
    /// otherwise the image is loaded and thumbnail is generated and put to
    /// the in-memory cache.  Since generation of thubnails is considered
    /// inexpensive, thumbnails are not put to the disk cache.
    func fetchThumbnailImage(for url: URL, size: CGSize) -> Future<UIImage> {
        let promise = Promise<UIImage>()
        
        let thumbnailKey = url.cacheThumbnailKey(for: size)
        if let cachedThumbnail = cachedImages.object(forKey: thumbnailKey) {
            promise.resolve(with: cachedThumbnail)
        } else {
            fetchImage(for: url).observe { [weak self] result in
                switch result {
                case .success(let image):
                    // `CGImageSourceCreateThumbnailAtIndex` could've been used here, but it's less flexible
                    let renderer = UIGraphicsImageRenderer(size: size)
                    let thumbnail = renderer.image { _ in
                        let scale = max(size.width / image.size.width, size.height / image.size.height)
                        let width = image.size.width * scale
                        let height = image.size.height * scale
                        let rect = CGRect(x: (size.width - width) / 2, y: (size.height - height) / 2, width: width, height: height)
                        
                        image.draw(in: rect)
                    }
                    
                    self?.cachedImages.setObject(thumbnail, forKey: thumbnailKey)
                
                    promise.resolve(with: thumbnail)
                case .failure(let error):
                    promise.reject(with: error)
                }
            }
        }
        
        return promise
    }
    
    /// Gets image from in-memory cache, if found it's returned;
    /// otherwise tries to get it from disk cache and if found it's put
    /// to in-memory cache and returned; otherwise tries to load it from
    /// the specified url, and upon success it's put to both in memory
    /// and disk caches.
    func fetchImage(for url: URL) -> Future<UIImage> {
        let promise = Promise<UIImage>()
        
        if let cachedImage = image(for: url) {
            promise.resolve(with: cachedImage)
            return promise
        }
        
        let key = url.cacheKey
        let fileUrl = cacheFolderURL?.appendingPathComponent(ImageFetcher.fileName(for: url))
        if let fileUrl = fileUrl, FileManager.default.fileExists(atPath: fileUrl.path) {
            if let data = try? Data(contentsOf: fileUrl, options: []), let image = UIImage(data: data) {
                self.cachedImages.setObject(image, forKey: key)
                promise.resolve(with: image)
                return promise
            }
        }
        
        httpClient.load(url: url).observe(on: .global()) { [weak self] result in
            switch result {
            case .failure(let error):
                promise.reject(with: error)
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    promise.reject(with: Error.imageDecoding)
                    return
                }
            
                // dealing with rendered image is more efficient as it's done on the background queue
                let renderer = UIGraphicsImageRenderer(size: image.size)
                let renderedImage = renderer.image { _ in
                    image.draw(in: CGRect(origin: .zero, size: image.size))
                }
            
                if let fileUrl = fileUrl, let pngData = renderedImage.pngData() {
                    try? pngData.write(to: fileUrl)
                }
            
                self?.cachedImages.setObject(renderedImage, forKey: key)
                promise.resolve(with: renderedImage)
            }
        }
        
        return promise
    }
    
    /// Returns image from the memory cache if it's there; nil otherwise
    func image(for url: URL) -> UIImage? {
        return cachedImages.object(forKey: url.cacheKey)
    }
}

private extension URL {
    var cacheKey: NSString { return path as NSString }
    
    func cacheThumbnailKey(for size: CGSize) -> NSString {
        return path.appending(NSCoder.string(for: size)) as NSString
    }
}
