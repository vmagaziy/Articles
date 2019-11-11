import UIKit

final class ArticleViewController: UIViewController {
    private lazy var noSelectionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = NSLocalizedString("No Selection", comment: "Text show when there is no active selection")
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = .gray
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var textView = ArticleTextView()
        
    private var currentView: UIView? {
        didSet {
            guard oldValue != currentView else { return }
            oldValue?.removeFromSuperview()
            if let currentView = currentView {
                view.addSubview(currentView)
            }
        }
    }
    
    var article: ArticleType? {
        didSet {
            title = article?.title
            if let article = article {
                textView.attributedText = article.attributedText
                currentView = textView
            } else {
                currentView = noSelectionLabel
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        article = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let readableContentGuideFrame = view.readableContentGuide.layoutFrame
        textView.textInsets = UIEdgeInsets(top: 16, left: readableContentGuideFrame.origin.x, bottom: 16, right: view.bounds.width - readableContentGuideFrame.maxX)
        textView.frame = view.bounds

        noSelectionLabel.frame = view.bounds.inset(by: view.layoutMargins)
    }
}

private extension ArticleType {
    var attributedText: NSAttributedString {
        return sections.map { $0.attributedText }.joined("\n\n")
    }
}

private extension SectionType {
    var attributedText: NSAttributedString {
        var components: [NSAttributedString] = []
        if let title = title {
            let titleText = NSAttributedString(string: title, attributes: [.font: UIFont.preferredFont(forTextStyle: .title2)])
            components.append(titleText)
        }
        
        components.append(contentsOf: bodyElements.map { $0.attributedText })
        
        return components.joined("\n")
    }
}

private extension BodyElementType {
    var attributedText: NSAttributedString {
        switch self {
        case .image(let url):
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            let placeholderSize = CGSize(width: 1, height: 1)
            let placeholderImage = UIGraphicsImageRenderer(size: placeholderSize).image { _ in
                UIColor.lightGray.set()
                UIRectFill(CGRect(origin: .zero, size: placeholderSize))
            }
            imageView.fetchImage(for: url, placeholderImage: placeholderImage)
            let imageAttachment = ImageTextAttachment(view: imageView)
            return NSAttributedString(attachment: imageAttachment)
        case .text(let string):
            return NSAttributedString(string: string + "\n", attributes: [.font: UIFont.preferredFont(forTextStyle: .body)])
        }
    }
}

extension Sequence where Element: NSAttributedString {
    func joined(_ separator: NSAttributedString) -> NSAttributedString {
        var isFirst = true
        return reduce(NSMutableAttributedString()) { result, string in
            if isFirst {
                isFirst = false
            } else {
                result.append(separator)
            }
            result.append(string)
            return result
        }
    }
    
    func joined(_ separator: String) -> NSAttributedString {
        return joined(NSAttributedString(string: separator))
    }
}
