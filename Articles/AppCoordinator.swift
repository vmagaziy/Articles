import UIKit

struct AppCoordinator {
    let rootViewController: UIViewController
    
    init() {
        let dataProvider = FeedDataProvider()

        let vc = FeedViewController(dataProvider: dataProvider)
        let nc = UINavigationController(rootViewController: vc)
        
        rootViewController = nc
    }
}
