import UIKit

final class FeedViewController: TableViewController<ArticleType> {
    private let dataProvider: FeedDataProviding
    
    init(dataProvider: FeedDataProviding) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
