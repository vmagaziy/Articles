import UIKit

class TextAttachment: NSTextAttachment {
    private(set) var view: UIView
    
    init(view: UIView) {
        self.view = view
        super.init(data: nil, ofType: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        return nil
    }
    
    func sizeThatFits(_ size: CGSize) -> CGSize {
        return view.sizeThatFits(size)
    }
    
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        let size = sizeThatFits(lineFrag.size)
        return CGRect(origin: .zero, size: size)
    }
}

final class ImageTextAttachment: TextAttachment {
    static let ratio: CGFloat = 4 / 3 // ratio should be determined by dimensions of fetched image and once the new height is defined, re-layout should be initiated; this should be done for more accurate image presentation if needed
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = size.width / ImageTextAttachment.ratio
        return CGSize(width: size.width, height: height)
    }
}
