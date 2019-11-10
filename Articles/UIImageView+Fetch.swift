import UIKit

extension UIImageView {
    private struct AssociatedKey {
        static var currentUrl = "currentUrl"
    }
    
    private var currentUrl: URL? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.currentUrl) as? URL
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.currentUrl, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func fetchThumbnailImage(for url: URL, size: CGSize, placeholderImage: UIImage? = nil, using imageFetcher: ImageFetching = ImageFetcher.shared) {
        currentUrl = url
        
        image = placeholderImage
        highlightedImage = placeholderImage
        
        imageFetcher.fetchThumbnailImage(for: url, size: size).observe { [weak self] result in
            guard let self = self, self.currentUrl == url, case .success(let image) = result else { return } // do nothing if showing an image for different url is already requested
            self.image = image
            self.highlightedImage = image
        }
    }
    
    func fetchImage(for url: URL, placeholderImage: UIImage? = nil, using imageFetcher: ImageFetching = ImageFetcher.shared) {
        if let cachedImage = imageFetcher.image(for: url) {
            resetImage()
            
            image = cachedImage
            highlightedImage = cachedImage
            
            return
        }
        
        currentUrl = url
        
        image = placeholderImage
        highlightedImage = placeholderImage
        
        imageFetcher.fetchImage(for: url).observe { [weak self] result in
            guard let self = self, self.currentUrl == url, case .success(let image) = result else { return } // do nothing if showing an image for different url is already requested
            self.image = image
            self.highlightedImage = image
        }
    }
    
    func resetImage() {
        currentUrl = nil
        image = nil
        highlightedImage = nil
    }
}
