import UIKit

final class AppCoordinator: NSObject {
    let rootViewController: UIViewController
    
    override init() {
        let splitViewController = UISplitViewController()
        rootViewController = splitViewController
        
        super.init()

        let dataProvider = FeedDataProvider()

        let feedVC = FeedViewController(dataProvider: dataProvider)
        let feedNC = UINavigationController(rootViewController: feedVC)
        
        let articleVC = ArticleViewController()
        let articleNC = UINavigationController(rootViewController: articleVC)
        
        feedVC.didSelect = { [articleVC, articleNC] article in
            splitViewController.showDetailViewController(articleNC, sender: self)
            
            articleVC.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            articleNC.navigationItem.leftItemsSupplementBackButton = true
            
            articleNC.popToRootViewController(animated: true)
            articleVC.article = article
        }

        splitViewController.viewControllers = [feedNC, articleNC]
        splitViewController.delegate = self
        articleNC.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
    }
}

extension AppCoordinator: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        guard let articleNC = secondaryViewController as? UINavigationController else { fatalError() }
        guard let articleVC = articleNC.topViewController as? ArticleViewController else { return false }
        guard articleVC.article == nil else { return false }
        return true // collapse is handled; secondary controller will be discarded
    }
}
