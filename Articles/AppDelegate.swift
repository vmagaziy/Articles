import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private lazy var appCoordinator = AppCoordinator()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        window.rootViewController = appCoordinator.rootViewController
        window.makeKeyAndVisible()
        
        self.window = window
        
        return true
    }
}
