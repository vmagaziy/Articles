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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    private func loadData() {
        source = .items(dataProvider.articles())
    }
}

private class TeaserTableViewCell: UITableViewCell {
    func configure(for article: ArticleType) {
        textLabel?.text = article.title
        textLabel?.numberOfLines = 0
    }
}
