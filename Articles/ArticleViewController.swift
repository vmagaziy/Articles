import UIKit

final class ArticleViewController: UIViewController {
    lazy var noSelectionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = NSLocalizedString("No Selection", comment: "Text show when there is no active selection")
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = .gray
        label.adjustsFontForContentSizeCategory = true
        view.addSubview(label)
        return label
    }()
    
    var article: ArticleType? {
        didSet {
            title = article?.title
            noSelectionLabel.isHidden = article != nil
            // TODO: IMPLEMENTATION GOES HERE
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noSelectionLabel.frame = view.bounds.inset(by: view.layoutMargins)
    }
}
