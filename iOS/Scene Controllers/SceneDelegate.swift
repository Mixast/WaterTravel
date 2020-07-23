import UIKit
import Firebase
import RxFirebase
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let navigator = Navigator()
    let api = FirebaseAPI.self
    private let bag = DisposeBag()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        api.auth().asObservable()
            .bind(onNext: { user in
                if user == nil {
                    guard let navigationController = self.window?.rootViewController as? UINavigationController else {
                        return
                    }
                    self.navigator.show(segue: .LoginViewController, sender: navigationController)
                } else {
                    guard let userBD = user else {
                        return
                    }
                    let controller = TabBarController(user: userBD)

                    self.window!.rootViewController = controller
                }
            })
            .disposed(by: bag)
        
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}

