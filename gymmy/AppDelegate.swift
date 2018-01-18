import UIKit

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
#if DEBUG
    let debug = true;
#else
    let debug = false;
#endif
    
    func startAppCenter() {
        var services = [
            MSAnalytics.self,
            MSCrashes.self,
        ]
        
        if debug {
            services.append(MSDistribute.self)
        }
        
        MSAppCenter.start("e6ffcad6-61cf-4a1f-970e-7ed173493396", withServices:services)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        startAppCenter()
        application.applicationSupportsShakeToEdit = true
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return MSDistribute.open(url)
    }
}

