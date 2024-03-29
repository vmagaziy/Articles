import UIKit

final class FeedViewController: TableViewController<Article> {
    private let dataProvider: FeedDataProviding
    
    init(dataProvider: FeedDataProviding) {
        self.dataProvider = dataProvider
        
        super.init(style: .grouped) { article -> TableViewCellDescriptor in
            return TableViewCellDescriptor(reuseIdentifier: "teaser") { (cell: TeaserTableViewCell) in
                cell.configure(for: article)
            }
        }
        
        title = NSLocalizedString("Articles", comment: "Title for the list of articles")
                
        didReload = { [unowned self] in self.loadData {} }
        didRequestRefresh = { [unowned self] in self.loadData($0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let splitViewController = splitViewController {
            clearsSelectionOnViewWillAppear = splitViewController.isCollapsed
        }
        super.viewWillAppear(animated)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        source = .loading
        loadData {}
    }
    
    private func loadData(_ completion: @escaping () -> Void) {
        let errorMessage = NSLocalizedString("Failed to get articles", comment: "Text shown on failed to load articles")
        dataProvider.articles().observe { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let articles):
                if articles.isEmpty {
                    self.source = .failure(errorMessage)
                } else {
                    self.source = .sections(articles.map { TableViewSection<Article>(title: nil, items: [$0]) })
                }
            case .failure(let error):
                if case .sections(let sections) = self.source, !sections.isEmpty {
                    // error happened on pull-to-refresh as sections are not empty, so don't replace current results being shown, but show an alert indicating a failure
                    let alert = UIAlertController(title: errorMessage, message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Action title in alert"), style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.source = .failure(error)
                }
            }
            
            completion()
        }
    }
}

private class TeaserTableViewCell: UITableViewCell {
    private static let imageRatio: CGFloat = 16 / 9
    private static let placholderImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in
        UIColor.lightGray.set()
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    private static let textEstimatedHeight: CGFloat = 100
    
    private let teaserImageView = UIImageView()
    private let teaserTextLabel = UILabel()
    
    private let highlightView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        view.alpha = 0
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(teaserImageView)
        contentView.addSubview(teaserTextLabel)
        addSubview(highlightView)

        teaserTextLabel.numberOfLines = 0
        
        teaserImageView.contentMode = .scaleAspectFill
        teaserImageView.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        func updateHighlightView() {
            highlightView.alpha = highlighted ? 1 : 0
        }
        if animated {
            UIView.animate(withDuration: 0.15, animations: updateHighlightView)
        } else {
            updateHighlightView()
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let textMargins = contentView.layoutMargins
        let textWidth = size.width - textMargins.left - textMargins.right
        let textHeight = teaserTextLabel.attributedText != nil ? teaserTextLabel.sizeThatFits(CGSize(width: textWidth, height: 0)).height : TeaserTableViewCell.textEstimatedHeight
        
        let imageHeight = teaserImageView.isHidden ? 0 : bounds.width / TeaserTableViewCell.imageRatio
        let height = imageHeight + textMargins.top + textHeight + textMargins.bottom
        return CGSize(width: size.width, height: height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        highlightView.frame = bounds
        
        let imageHeight = teaserImageView.isHidden ? 0 : bounds.width / TeaserTableViewCell.imageRatio
        teaserImageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: imageHeight)
        
        let textBounds = contentView.bounds
        let textMargins = contentView.layoutMargins
        let textInsetBounds = textBounds.inset(by: textMargins)
        let textHeight = ceil(textInsetBounds.height - imageHeight) // rounding needed as text needs a bigger height; apparently this difference is caused by hairline added by UIKit
        
        teaserTextLabel.frame = CGRect(x: textInsetBounds.minX, y: textInsetBounds.minY + imageHeight, width: textInsetBounds.width, height: textHeight)
    }
        
    func configure(for article: Article) {
        teaserTextLabel.attributedText = article.attributedTeaserText
        if let url = article.image {
            let viewWidth = contentView.bounds.width
            let imageHeight = viewWidth / TeaserTableViewCell.imageRatio
            teaserImageView.fetchThumbnailImage(for: url, size: CGSize(width: viewWidth, height: imageHeight), placeholderImage: TeaserTableViewCell.placholderImage)
            teaserImageView.isHidden = false
        } else {
            teaserImageView.resetImage()
            teaserImageView.isHidden = true
        }
    }
}

private extension Article {
    var attributedTeaserText: NSAttributedString {
        let attributedText = NSMutableAttributedString()
        
        let separator = NSAttributedString(string: "\n", attributes: [.font: UIFont.systemFont(ofSize: 5)])
        
        let titleText = NSAttributedString(string: title, attributes: [.font: UIFont.preferredFont(forTextStyle: .title2)])
        attributedText.append(titleText)
        
        if let publisher = publisher {
            attributedText.append(separator)
         
            let publisherText = NSAttributedString(string: publisher, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption2), .foregroundColor: UIColor.gray])
            attributedText.append(publisherText)
        }
        
        return attributedText
    }

}
