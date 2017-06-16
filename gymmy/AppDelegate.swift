import UIKit

import MobileCenter
import MobileCenterAnalytics
import MobileCenterCrashes
import MobileCenterDistribute

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        MSMobileCenter.start("e6ffcad6-61cf-4a1f-970e-7ed173493396", withServices:[
            MSAnalytics.self,
            MSCrashes.self,
            MSDistribute.self
        ])
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return MSDistribute.open(url)
    }
}

