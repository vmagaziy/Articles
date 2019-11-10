import UIKit

final class FeedViewController: TableViewController<ArticleType> {
    private let dataProvider: FeedDataProviding
    
    init(dataProvider: FeedDataProviding) {
        self.dataProvider = dataProvider
        
        super.init(style: .plain) { article -> TableViewCellDescriptor in
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
        loadData {}
    }
    
    private func loadData(_ completion: @escaping () -> Void) {
        source = .loading

        dataProvider.articles().observe { [weak self] result in
            switch result {
            case .success(let articles):
                self?.source = .items(articles)
            case .failure(let error):
                self?.source = .failure(error)
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [teaserImageView, teaserTextLabel].forEach(contentView.addSubview)
        
        teaserTextLabel.numberOfLines = 0
        
        teaserImageView.contentMode = .scaleAspectFill
        teaserImageView.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        let imageHeight = teaserImageView.isHidden ? 0 : bounds.width / TeaserTableViewCell.imageRatio
        teaserImageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: imageHeight)
        
        let textBounds = contentView.bounds
        let textMargins = contentView.layoutMargins
        let textInsetBounds = textBounds.inset(by: textMargins)
        let textHeight = ceil(textInsetBounds.height - imageHeight) // rounding needed as text needs a bigger height; apparently this difference is caused by hairline added by UIKit
        
        teaserTextLabel.frame = CGRect(x: textInsetBounds.minX, y: textInsetBounds.minY + imageHeight, width: textInsetBounds.width, height: textHeight)
    }
        
    func configure(for article: ArticleType) {
        teaserTextLabel.attributedText = article.attributedText
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

private extension ArticleType {
    var attributedText: NSAttributedString {
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
