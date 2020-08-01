import UIKit
import Firebase
import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Override point for customization after application launch.
        IQKeyboardManager.shared().isEnabled = true            //Включаем сдвиг при наезде клавиатуры на поле ввода
        IQKeyboardManager.shared().enableDebugging = false // Debugging
        IQKeyboardManager.shared().isEnableAutoToolbar = true              //Убираем Auto Toolbar
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 100       // Делаем растояние сдвига = 100
        IQKeyboardManager.shared().keyboardAppearance = .dark

        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

