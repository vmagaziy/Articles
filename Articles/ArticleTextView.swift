import UIKit

final class ArticleTextView: UITextView {
    private var attachments = [TextAttachment]() {
        didSet {
            let newSet = Set<TextAttachment>(attachments)
            let oldSet = Set<TextAttachment>(oldValue)
            oldSet.subtracting(newSet).map { $0.view }.forEach { $0.removeFromSuperview() }
            newSet.subtracting(oldSet).map { $0.view }.forEach(addSubview)
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        textDragInteraction?.isEnabled = false
        isEditable = false
        
        layoutManager.allowsNonContiguousLayout = false
        layoutManager.delegate = self
        textStorage.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let readableContentGuideFrame = readableContentGuide.layoutFrame
        textContainerInset = UIEdgeInsets(top: 16, left: readableContentGuideFrame.origin.x, bottom: 16, right: bounds.width - readableContentGuideFrame.maxX)
    }
}

private extension ArticleTextView {
    func layoutAttachments() {
        let isEdgeToEdge = textContainerInset.left < 32
        
        textStorage.attachmentsAndRanges.forEach { (attachment, range) in
            let index = layoutManager.glyphRange(forCharacterRange: NSRange(location: range.location, length: 1), actualCharacterRange: nil).location
            let attachmentSize = layoutManager.attachmentSize(forGlyphAt: index)
            let lineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: nil)
            let location = layoutManager.location(forGlyphAt: index)
            
            let rect = CGRect(origin: CGPoint(x: isEdgeToEdge ? 0 : lineFragmentRect.minX, y: lineFragmentRect.minY + location.y - attachmentSize.height), size: CGSize(width: isEdgeToEdge ? bounds.width : attachmentSize.width, height: attachmentSize.height))
            
            attachment.view.frame = rect.offsetBy(dx: isEdgeToEdge ? 0 : textContainerInset.left, dy: textContainerInset.top)
        }
    }
}

extension ArticleTextView: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        guard layoutFinishedFlag else { return }
        layoutAttachments()
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, textContainer: NSTextContainer, didChangeGeometryFrom oldSize: CGSize) {
        guard oldSize.width != textContainer.size.width else { return }
        layoutManager.ensureLayout(for: textContainer)
    }
}

extension ArticleTextView: NSTextStorageDelegate {
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        guard editedMask.contains(.editedAttributes) else { return }
        attachments = textStorage.attachmentsAndRanges.map { $0.attachment }
    }
}

private extension NSAttributedString {
    var attachmentsAndRanges: [(attachment: TextAttachment, range: NSRange)] {
        var ranges: [(TextAttachment, NSRange)] = []
        enumerateAttribute(.attachment, in: NSRange(location: 0, length: length)) { value, range, _ in
            guard let attachment = value as? TextAttachment else { return }
            ranges.append((attachment, range))
        }
        return ranges
    }
}
