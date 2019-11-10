import UIKit

struct AppCoordinator {
    let rootViewController: UIViewController
    
    init() {
        let vc = FeedViewController()
        let nc = UINavigationController(rootViewController: vc)
        
        rootViewController = nc
    }
}
