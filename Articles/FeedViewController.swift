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
                
        didReload = { [unowned self] in self.loadData() }
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
        loadData()
    }
    
    private func loadData() {
        source = .loading

        dataProvider.articles().observe { [weak self] result in
            switch result {
            case .success(let articles):
                self?.source = .items(articles)
            case .failure(let error):
                self?.source = .failure(error)
            }
        }
    }
}

private class TeaserTableViewCell: UITableViewCell {
    func configure(for article: ArticleType) {
        textLabel?.attributedText = article.attributedText
        textLabel?.numberOfLines = 0
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
