import UIKit

final class ArticleViewController: UIViewController {
    var article: ArticleType? {
        didSet {
            title = article?.title
            // TODO: IMPLEMENTATION GOES HERE
        }
    }
}
